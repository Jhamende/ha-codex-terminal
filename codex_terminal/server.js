#!/usr/bin/env node
const http=require('http'),fs=require('fs'),path=require('path'),{spawn}=require('child_process'),WebSocket=require('ws'),Busboy=require('busboy');
const PORT=8099,DATA='/data/codex',UPLOAD=path.join(DATA,'uploads'),STATE=path.join(DATA,'ui-state.json'),PUBLIC='/app/public';
fs.mkdirSync(UPLOAD,{recursive:true});
let state={threadId:null,messages:[],activities:[],permissionMode:process.env.PERMISSION_MODE||'default',workingDirectory:process.env.WORKING_DIRECTORY||'/config'};
try{state={...state,...JSON.parse(fs.readFileSync(STATE,'utf8'))}}catch{}
const save=()=>fs.writeFileSync(STATE,JSON.stringify(state,null,2));
let rpcId=1,pending=new Map(),ready=false,buf='';
const codex=spawn('codex',['app-server','--listen','stdio://'],{env:{...process.env,HOME:DATA,CODEX_HOME:path.join(DATA,'.codex')},stdio:['pipe','pipe','inherit']});
const rpc=(method,params={})=>new Promise((resolve,reject)=>{const id=rpcId++;pending.set(id,{resolve,reject});codex.stdin.write(JSON.stringify({id,method,params})+'\n')});
function broadcast(o){const s=JSON.stringify(o);wss.clients.forEach(c=>c.readyState===WebSocket.OPEN&&c.send(s))}
function activity(item,status='running'){
 const id=item.id||item.itemId||('activity-'+Date.now()+'-'+Math.random());
 let a=state.activities.find(x=>x.id===id);
 const type=item.type||'tool';
 const title= type==='commandExecution' ? ('Commande · '+(item.command||item.cmd||'')) : type==='fileChange' ? ('Fichier · '+(item.path||item.filePath||'modification')) : type==='mcpToolCall' ? ('Outil · '+(item.tool||item.name||'')) : type;
 const detail=item.output||item.aggregatedOutput||item.diff||item.result||item.error||'';
 if(!a){a={id,type,title,detail,status,time:Date.now()};state.activities.push(a);if(state.activities.length>300)state.activities=state.activities.slice(-300)}
 else Object.assign(a,{title,detail,status});
 save();broadcast({type:'activity',activity:a});
}
function add(role,text,extra={}){if(!text&&!extra.attachments?.length)return;const m={id:Date.now()+'-'+Math.random(),role,text,time:Date.now(),...extra};state.messages.push(m);if(state.messages.length>500)state.messages=state.messages.slice(-500);save();broadcast({type:'message',message:m})}
codex.stdout.on('data',d=>{buf+=d;let i;while((i=buf.indexOf('\n'))>=0){const line=buf.slice(0,i);buf=buf.slice(i+1);if(!line.trim())continue;let m;try{m=JSON.parse(line)}catch{continue}
 if(m.id&&pending.has(m.id)){const q=pending.get(m.id);pending.delete(m.id);m.error?q.reject(m.error):q.resolve(m.result);continue}
 const method=m.method||'',p=m.params||{};
 if(method==='item/started'&&p.item&&p.item.type!=='agentMessage')activity(p.item,'running');
 else if(method==='item/completed'&&p.item&&p.item.type!=='agentMessage')activity(p.item,p.item.error?'error':'completed');
 else if(method.includes('/delta')&&method!=='item/agentMessage/delta'&&p.itemId){const a=state.activities.find(x=>x.id===p.itemId);if(a){a.detail=(a.detail||'')+(p.delta||p.output||'');save();broadcast({type:'activity',activity:a})}}
 else if(method==='item/agentMessage/delta')broadcast({type:'delta',delta:p.delta||'',itemId:p.itemId});
 else if(method==='item/completed'&&p.item?.type==='agentMessage'){const text=p.item.text||((p.item.content||[]).map(x=>x.text||'').join(''));add('assistant',text)}
 else if(method==='turn/started')broadcast({type:'status',status:'thinking'});
 else if(method==='turn/completed')broadcast({type:'status',status:'ready'});
 else if(method.includes('requestApproval'))broadcast({type:'approval',requestId:m.id,method,params:p});
}});
async function boot(){await rpc('initialize',{clientInfo:{name:'ha_codex_terminal',title:'Home Assistant Codex',version:'0.5.0'},capabilities:{experimentalApi:true}});codex.stdin.write(JSON.stringify({method:'initialized',params:{}})+'\n');ready=true;if(state.threadId){try{await rpc('thread/resume',{threadId:state.threadId,excludeTurns:true})}catch(e){console.error('resume failed',e);state.threadId=null;save()}}}
boot().catch(e=>console.error('Codex app-server init failed',e));
function policy(){if(state.permissionMode==='full-access')return{approvalPolicy:'never',sandbox:'danger-full-access'};if(state.permissionMode==='full-auto')return{approvalPolicy:'never',sandbox:'workspace-write'};return{approvalPolicy:'on-request',sandbox:'workspace-write'}}
async function ensureThread(){if(state.threadId)return state.threadId;if(!ready)throw new Error('Codex démarre encore');const r=await rpc('thread/start',{cwd:state.workingDirectory,...policy()});state.threadId=r.thread.id;save();broadcast({type:'thread',threadId:state.threadId});return state.threadId}
async function send(text,attachments=[]){const id=await ensureThread();add('user',text,{attachments});const input=[];if(text)input.push({type:'text',text});for(const f of attachments)input.push({type:'localImage',path:f.path});return rpc('turn/start',{threadId:id,input,...policy()})}
const server=http.createServer((req,res)=>{
 const u=new URL(req.url,'http://localhost'),pn=u.pathname;
 if(req.method==='GET'&&(pn==='/'||pn.endsWith('/'))){res.setHeader('content-type','text/html;charset=utf-8');res.setHeader('cache-control','no-store');return fs.createReadStream(path.join(PUBLIC,'index.html')).pipe(res)}
 if(req.method==='GET'&&pn.endsWith('/state')){res.setHeader('content-type','application/json');return res.end(JSON.stringify(state))}
 if(req.method==='POST'&&pn.endsWith('/upload')){const bb=Busboy({headers:req.headers,limits:{fileSize:25*1024*1024,files:5}}),files=[];bb.on('file',(n,f,info)=>{const safe=Date.now()+'-'+path.basename(info.filename).replace(/[^a-zA-Z0-9._-]/g,'_');const dest=path.join(UPLOAD,safe);f.pipe(fs.createWriteStream(dest));files.push({name:info.filename,path:dest,type:info.mimeType})});bb.on('close',()=>{res.setHeader('content-type','application/json');res.end(JSON.stringify({files}))});return req.pipe(bb)}
 res.statusCode=404;res.end('Not found')
});
const wss=new WebSocket.Server({noServer:true});server.on('upgrade',(req,socket,head)=>wss.handleUpgrade(req,socket,head,ws=>wss.emit('connection',ws,req)));
wss.on('connection',ws=>{ws.send(JSON.stringify({type:'state',state}));ws.on('message',async raw=>{let m;try{m=JSON.parse(raw)}catch{return}try{
 if(m.type==='send')await send(m.text||'',m.attachments||[]);
 else if(m.type==='newThread'){state.threadId=null;state.messages=[];state.activities=[];save();broadcast({type:'state',state})}
 else if(m.type==='settings'){if(['default','full-auto','full-access'].includes(m.permissionMode))state.permissionMode=m.permissionMode;save();broadcast({type:'state',state})}
 else if(m.type==='approval'&&m.id)codex.stdin.write(JSON.stringify({id:m.id,result:{decision:m.decision}})+'\n');
}catch(e){ws.send(JSON.stringify({type:'error',message:e.message||JSON.stringify(e)}))}})});
server.listen(PORT,'0.0.0.0',()=>console.log('Persistent Codex Chat UI listening on',PORT));
