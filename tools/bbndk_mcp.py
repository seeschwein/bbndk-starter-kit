#!/usr/bin/env python3
import json, os, pathlib, subprocess, sys
ROOT = pathlib.Path(os.environ.get("BBNDK_WORKSPACE", "/workspace")).resolve()
PROTOCOL = "2024-11-05"
def reply(obj):
    sys.stdout.write(json.dumps(obj, separators=(",", ":")) + "\n"); sys.stdout.flush()
def result(i, content): reply({"jsonrpc":"2.0","id":i,"result":content})
def error(i, code, message): reply({"jsonrpc":"2.0","id":i,"error":{"code":code,"message":message}})
def safe_path(value):
    p = (ROOT/value).resolve() if not pathlib.Path(value).is_absolute() else pathlib.Path(value).resolve()
    if p != ROOT and ROOT not in p.parents: raise ValueError("Path escapes /workspace")
    return p
def text(value): return {"content":[{"type":"text","text":value}],"isError":False}
def run(argv,cwd):
    p=subprocess.run(argv,cwd=cwd,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=300,env=os.environ.copy())
    return p.returncode,p.stdout[-50000:]
TOOLS=[
 {"name":"list_files","description":"List project files under /workspace.","inputSchema":{"type":"object","properties":{"path":{"type":"string","default":"."}}}},
 {"name":"read_file","description":"Read a UTF-8 text file under /workspace.","inputSchema":{"type":"object","required":["path"],"properties":{"path":{"type":"string"}}}},
 {"name":"write_file","description":"Write a UTF-8 text file under /workspace.","inputSchema":{"type":"object","required":["path","content"],"properties":{"path":{"type":"string"},"content":{"type":"string"}}}},
 {"name":"make","description":"Run an allowlisted make target.","inputSchema":{"type":"object","properties":{"path":{"type":"string","default":"."},"target":{"type":"string","enum":["all","compile","package","inspect","clean"],"default":"all"}}}},
 {"name":"compile_c","description":"Compile one C file for a BB10 ARM device.","inputSchema":{"type":"object","required":["path","source","output"],"properties":{"path":{"type":"string"},"source":{"type":"string"},"output":{"type":"string"}}}},
 {"name":"package_bar","description":"Create an unsigned development BAR.","inputSchema":{"type":"object","required":["path","bar","descriptor"],"properties":{"path":{"type":"string"},"bar":{"type":"string"},"descriptor":{"type":"string"}}}}
]
def call(name,a):
    if name=="list_files":
        p=safe_path(a.get("path",".")); rows=[]
        for x in sorted(p.rglob("*")):
            if len(rows)>=1000: break
            rows.append(str(x.relative_to(ROOT))+("/" if x.is_dir() else ""))
        return text("\n".join(rows))
    if name=="read_file": return text(safe_path(a["path"]).read_text(errors="replace")[:100000])
    if name=="write_file":
        p=safe_path(a["path"]); p.parent.mkdir(parents=True,exist_ok=True); p.write_text(a["content"]); return text(f"Wrote {p.relative_to(ROOT)}")
    cwd=safe_path(a.get("path","."))
    if name=="make": argv=["make",a.get("target","all")]
    elif name=="compile_c": argv=["qcc","-Vgcc_ntoarmv7le",a["source"],"-o",a["output"]]
    elif name=="package_bar": argv=["blackberry-nativepackager","-package",a["bar"],"-devMode",a["descriptor"]]
    else: raise ValueError("Unknown tool")
    code,out=run(argv,cwd); return {"content":[{"type":"text","text":out}],"isError":code!=0}
for line in sys.stdin:
    try:
        req=json.loads(line); i=req.get("id"); method=req.get("method")
        if method=="initialize": result(i,{"protocolVersion":req.get("params",{}).get("protocolVersion",PROTOCOL),"capabilities":{"tools":{}},"serverInfo":{"name":"bbndk-workspace","version":"0.1.0"}})
        elif method=="notifications/initialized": pass
        elif method=="ping": result(i,{})
        elif method=="tools/list": result(i,{"tools":TOOLS})
        elif method=="tools/call": result(i,call(req["params"]["name"],req["params"].get("arguments",{})))
        elif i is not None: error(i,-32601,"Method not found")
    except Exception as e:
        if 'i' in locals() and i is not None: error(i,-32000,str(e))
