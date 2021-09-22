import sys,subprocess
try:
    import compdb
except:
    p= subprocess.Popen(['pip','install','compdb','--user'])
    p.wait()
    import compdb

def main():
    build = "build"
    if(len( sys.argv )>=2):
        build = sys.argv[1]
    process = subprocess.Popen(['compdb','-p',build, 'list'],stdout=subprocess.PIPE)
    text = process.communicate()[0]
    open('compile_commands.json','wb').write(text)
    print("Wrote compile_commands.json successfully")
main()







