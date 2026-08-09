#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import ast, hashlib, json, re, subprocess, sys, xml.etree.ElementTree as ET
try:
    import yaml
except Exception:
    yaml = None

ROOT=Path(__file__).resolve().parents[1]
checks=[]
def check(name, cond, detail=''):
    checks.append({'name':name,'passed':bool(cond),'detail':detail if not cond else ''})

def rel_imports_resolve():
    failures=[]
    for p in ROOT.joinpath('lib').rglob('*.dart'):
        text=p.read_text(encoding='utf-8')
        for m in re.finditer(r"import\s+['\"]([^'\"]+)['\"]", text):
            target=m.group(1)
            if target.startswith(('.', '..')):
                q=(p.parent/target).resolve()
                if not q.exists(): failures.append(f'{p.relative_to(ROOT)} -> {target}')
    return failures

def lexical_balance():
    failures=[]
    pairs={'(':')','[':']','{':'}'}
    for p in ROOT.joinpath('lib').rglob('*.dart'):
        s=p.read_text(encoding='utf-8')
        # Strip simple quoted strings and comments before approximate delimiter check.
        s=re.sub(r"'''[\s\S]*?'''|\"\"\"[\s\S]*?\"\"\"",'',s)
        s=re.sub(r"'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\"",'',s)
        s=re.sub(r'//.*','',s)
        stack=[]
        for ch in s:
            if ch in pairs: stack.append(ch)
            elif ch in pairs.values():
                if not stack or pairs[stack.pop()]!=ch:
                    failures.append(str(p.relative_to(ROOT))); break
        else:
            if stack: failures.append(str(p.relative_to(ROOT)))
    return failures

pub=(ROOT/'pubspec.yaml').read_text()
check('pubspec version 1.0.0+10','version: 1.0.0+10' in pub)
raw=json.loads((ROOT/'assets/content/curriculum.json').read_text(encoding='utf-8'))
courses=raw['courses']; lessons=[l for c in courses for l in c['lessons']]
practicals=[l for l in lessons if l.get('practicalKind')]
check('course count 9',len(courses)==9,f'found {len(courses)}')
check('lesson count 60',len(lessons)==60,f'found {len(lessons)}')
check('interactive practical count 40',len(practicals)==40,f'found {len(practicals)}')
check('unique course ids',len({c['id'] for c in courses})==len(courses))
check('unique lesson ids',len({l['id'] for l in lessons})==len(lessons))

for f in [
    '.github/workflows/android-apk.yml','scripts/bootstrap_android.sh',
    'scripts/apply_android_branding.py','scripts/build_android_release.sh',
    'ANDROID_BUILD_GUIDE.md','V10_ANDROID_RELEASE_HARDENING_STATUS.md',
    'assets/branding/app_icon_1024.png','assets/branding/splash_logo.png',
    'tool/android_overlay/res/values/styles.xml','tool/android_overlay/res/values-v31/styles.xml',
]:
    check(f'file exists {f}',(ROOT/f).is_file())

# Validate shell syntax.
for f in ['scripts/bootstrap_android.sh','scripts/build_android_release.sh']:
    cp=subprocess.run(['bash','-n',str(ROOT/f)],capture_output=True,text=True)
    check(f'bash syntax {f}',cp.returncode==0,cp.stderr.strip())

# Validate Python helper syntax without importing/executing it.
for f in ['scripts/apply_android_branding.py','scripts/source_release_check.py']:
    try:
        ast.parse((ROOT/f).read_text(encoding='utf-8'))
        ok=True; detail=''
    except SyntaxError as e:
        ok=False; detail=str(e)
    check(f'python syntax {f}',ok,detail)

# XML resources must be well formed.
for p in ROOT.joinpath('tool/android_overlay/res').rglob('*.xml'):
    try:
        ET.parse(p); ok=True; detail=''
    except Exception as e:
        ok=False; detail=str(e)
    check(f'xml parse {p.relative_to(ROOT)}',ok,detail)

# Workflow structure/syntax.
workflow=(ROOT/'.github/workflows/android-apk.yml').read_text()
check('workflow uses Flutter stable','channel: stable' in workflow)
check('workflow runs flutter analyze','flutter analyze' in workflow)
check('workflow runs flutter test','flutter test' in workflow)
check('workflow builds release apk','flutter build apk --release' in workflow)
check('workflow uploads artifact','actions/upload-artifact@v4' in workflow)
if yaml:
    try:
        yaml.safe_load(workflow); ok=True; detail=''
    except Exception as e:
        ok=False; detail=str(e)
    check('workflow YAML parses',ok,detail)

bootstrap=(ROOT/'scripts/bootstrap_android.sh').read_text()
check('bootstrap uses current Flutter scaffold','flutter create' in bootstrap and '--platforms=android' in bootstrap)
check('bootstrap sets organization','--org in.nexoofficial' in bootstrap)
check('bootstrap applies branding','apply_android_branding.py' in bootstrap)
brand=(ROOT/'scripts/apply_android_branding.py').read_text()
check('app label configured','ASTRA Computer Academy' in brand)
check('cleartext disabled','usesCleartextTraffic' in brand and 'false' in brand)
check('system backup disabled','allowBackup' in brand and 'false' in brand)
check('no release INTERNET permission overlay','android.permission.INTERNET' not in '\n'.join(p.read_text(errors='ignore') for p in ROOT.joinpath('tool/android_overlay').rglob('*') if p.is_file()))

# PNG signature + dimensions with Pillow if available.
try:
    from PIL import Image
    im=Image.open(ROOT/'assets/branding/app_icon_1024.png')
    check('launcher source is 1024x1024',im.size==(1024,1024),str(im.size))
    for den,size in {'mdpi':48,'hdpi':72,'xhdpi':96,'xxhdpi':144,'xxxhdpi':192}.items():
        q=ROOT/f'tool/android_overlay/res/mipmap-{den}/ic_launcher.png'
        im=Image.open(q)
        check(f'launcher icon {den} size',im.size==(size,size),str(im.size))
except Exception as e:
    check('branding image inspection',False,str(e))

imports=rel_imports_resolve()
check('all relative Dart imports resolve',not imports,'; '.join(imports[:10]))
balance=lexical_balance()
check('Dart lexical delimiters balanced',not balance,'; '.join(balance[:10]))

final_exam=(ROOT/'lib/services/final_exam_service.dart').read_text()
# count explicit component declarations in list
component_block=final_exam.split('static const components',1)[1].split('];',1)[0]
component_count=len(re.findall(r'FinalExamComponent\(', component_block))
check('final exam remains 9 components',component_count==9,f'found {component_count}')
db=(ROOT/'lib/data/app_database.dart').read_text()
check('database remains schema v4',re.search(r'version:\s*4',db) is not None)


home=(ROOT/'lib/screens/home_screen.dart').read_text()
check('narrow dashboard breakpoint added','constraints.maxWidth < 390' in home)
check('narrow continue-card breakpoint added','constraints.maxWidth < 350' in home)

passed=sum(c['passed'] for c in checks)
report={
    'version':'1.0.0',
    'status':'PASS' if passed==len(checks) else 'FAIL',
    'summary':{'passed':passed,'total':len(checks)},
    'environment':{
        'flutterSdkAvailable':False,
        'dartSdkAvailable':False,
        'note':'Source/build-contract validation only. GitHub Actions/local Flutter build remains the compile/runtime gate.'
    },
    'metrics':{'courses':len(courses),'lessons':len(lessons),'interactivePracticals':len(practicals),'finalExamComponents':component_count,'databaseSchema':4},
    'checks':checks,
}
(ROOT/'SELF_TEST_REPORT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding='utf-8')
print(f"{report['status']}: {passed}/{len(checks)}")
if report['status']!='PASS':
    for c in checks:
        if not c['passed']: print('FAIL',c['name'],c['detail'])
    sys.exit(1)
