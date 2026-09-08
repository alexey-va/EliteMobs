#!/usr/bin/env python3
"""Build a narrowly scoped, hash-pinned patch of the deployed EliteMobs 10.8.1 binary."""
import argparse, hashlib, json, re, subprocess, tempfile, zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE_SHA256 = 'aac94a889701633d1746aa81646ddf05c1b0a8d1ce6b37fcdd69b011da766d24'
VERSION = '10.8.1-ruscrafting.1'
PACKAGE = 'com/magmaguy/elitemobs/playerdata/database/'
OWNERS = ('PlayerData', 'PlayerDataRepository')
SOURCES = OWNERS
METADATA = 'META-INF/ruscrafting-patch.json'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def owned(name):
    return any(name == PACKAGE + c + '.class' or name.startswith(PACKAGE + c + '$') for c in OWNERS)

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--patch', choices=('persistence', 'wormhole'), default='persistence')
p.add_argument('--base-jar', type=Path, required=True)
p.add_argument('--classpath', required=True, help='Compile-only jars, separated by the platform path separator')
p.add_argument('--lombok', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
if a.patch == 'wormhole':
    BASE_SHA256 = '404e31c5018c0e30add28fc56fea4aa844864df59a27cdc13d697838c17a5d15'
    VERSION = '10.8.1-ruscrafting.2'
    PACKAGE = 'com/magmaguy/elitemobs/wormhole/'
    SOURCES = ('WormholeManager',)
    OWNERS = ('WormholeManager$PlayerWormholeData',)
    METADATA = 'META-INF/ruscrafting-wormhole-patch.json'
if sha(a.base_jar) != BASE_SHA256:
    raise SystemExit('Refusing a baseline other than the verified EliteMobs 10.8.1 artifact')
if a.output.exists():
    raise SystemExit('Output already exists; use a new immutable candidate path')
revision = subprocess.check_output(['git','-C',str(ROOT),'rev-parse','HEAD'],text=True).strip()
status = subprocess.check_output(['git','-C',str(ROOT),'status','--porcelain','--','src/main/java/'+PACKAGE,'ruscrafting'],text=True)
if status.strip():
    raise SystemExit('Publish the owned source paths before building a release candidate')
with tempfile.TemporaryDirectory(prefix='elitemobs-build-') as directory:
    work = Path(directory); sources = work/'src'; classes = work/'classes'; sources.mkdir()
    for c in SOURCES:
        text = (ROOT/'src/main/java'/PACKAGE/(c+'.java')).read_text()
        (sources/(c+'.java')).write_text(text.replace('com.magmaguy.magmacore','com.magmaguy.elitemobs.magmacore'))
    import os
    cp = str(a.base_jar.resolve()) + os.pathsep + a.classpath
    subprocess.run(['javac','--release','21','-encoding','UTF-8','-cp',cp,'-processorpath',str(a.lombok),'-d',str(classes)]+[str(f) for f in sorted(sources.glob('*.java'))],check=True)
    compiled = {f.relative_to(classes).as_posix():f.read_bytes() for f in classes.rglob('*.class')}
    allowed = lambda name: any(name == PACKAGE + c + '.class' or name.startswith(PACKAGE + c + '$') for c in SOURCES)
    if not all(allowed(name) for name in compiled):
        raise SystemExit('Unexpected compiled class outside selected source families')
    replacements = {name:data for name,data in compiled.items() if owned(name)}
    if not replacements or not all(owned(n) for n in replacements):
        raise SystemExit('Unexpected compiled class outside selected patch')
    for c in OWNERS:
        cls=(PACKAGE+c).replace('/','.')
        old=subprocess.check_output(['javap','-classpath',str(a.base_jar),cls],text=True)
        new=subprocess.check_output(['javap','-classpath',str(classes),cls],text=True)
        if old != new:
            raise SystemExit('Public/package ABI changed: '+cls)
    metadata = {'patch':a.patch,'version':VERSION,'sourceRevision':revision,'baselineSha256':BASE_SHA256,
                'javac':subprocess.check_output(['javac','-version'],text=True).strip(),
                'compileDependencies':[{ 'file':Path(f).name,'sha256':sha(Path(f))} for f in a.classpath.split(os.pathsep)],
                'classes':sorted(replacements)}
    a.output.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(a.base_jar) as base, zipfile.ZipFile(a.output,'x',zipfile.ZIP_DEFLATED) as out:
        for entry in base.infolist():
            if owned(entry.filename):
                continue
            data=base.read(entry.filename)
            if entry.filename=='plugin.yml':
                data,count=re.subn(rb'(?m)^version:.*$',('version: '+VERSION).encode(),data)
                if count != 1: raise SystemExit('Missing or ambiguous plugin version')
            out.writestr(entry,data)
        for name,data in sorted(replacements.items()):
            info=zipfile.ZipInfo(name,date_time=(2026,9,8,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;out.writestr(info,data)
        out.writestr(METADATA,json.dumps(metadata,indent=2)+'\n')
    with zipfile.ZipFile(a.base_jar) as base,zipfile.ZipFile(a.output) as out:
        assert out.testzip() is None
        assert len(out.namelist()) == len(set(out.namelist()))
        for name in base.namelist():
            if not owned(name) and name != 'plugin.yml':
                assert base.read(name)==out.read(name), name
    print(json.dumps({'artifact':str(a.output.resolve()),'sha256':sha(a.output),**metadata},indent=2))
