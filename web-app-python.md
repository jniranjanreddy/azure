## How to create a python web app in Azure.
```
root@ubansinode1:/myworkspace# python3 -m venv venv
root@ubansinode1:/myworkspace# source venv/bin/activate
(venv) root@ubansinode1:/myworkspace# pip install flask
Collecting flask
  Downloading Flask-2.3.2-py3-none-any.whl (96 kB)
     |████████████████████████████████| 96 kB 563 kB/s
Collecting Werkzeug>=2.3.3
  Downloading Werkzeug-2.3.6-py3-none-any.whl (242 kB)
     |████████████████████████████████| 242 kB 2.1 MB/s
Collecting Jinja2>=3.1.2
  Downloading Jinja2-3.1.2-py3-none-any.whl (133 kB)
     |████████████████████████████████| 133 kB 2.0 MB/s
Collecting itsdangerous>=2.1.2
  Downloading itsdangerous-2.1.2-py3-none-any.whl (15 kB)
Collecting importlib-metadata>=3.6.0; python_version < "3.10"
  Downloading importlib_metadata-6.7.0-py3-none-any.whl (22 kB)
Collecting click>=8.1.3
  Downloading click-8.1.3-py3-none-any.whl (96 kB)
     |████████████████████████████████| 96 kB 1.8 MB/s
Collecting blinker>=1.6.2
  Downloading blinker-1.6.2-py3-none-any.whl (13 kB)
Collecting MarkupSafe>=2.1.1
  Downloading MarkupSafe-2.1.3-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (25 kB)
Collecting zipp>=0.5
  Downloading zipp-3.15.0-py3-none-any.whl (6.8 kB)
Installing collected packages: MarkupSafe, Werkzeug, Jinja2, itsdangerous, zipp, importlib-metadata, click, blinker, flask
Successfully installed Jinja2-3.1.2 MarkupSafe-2.1.3 Werkzeug-2.3.6 blinker-1.6.2 click-8.1.3 flask-2.3.2 importlib-metadata-6.7.0 itsdangerous-2.1.2 zipp-3.15.0


(venv) root@ubansinode1:/myworkspace# mkdir BestBikeApp
(venv) root@ubansinode1:/myworkspace# cd BestBikeApp/
(venv) root@ubansinode1:/myworkspace/BestBikeApp# vim  application.py
(venv) root@ubansinode1:/myworkspace/BestBikeApp# cat application.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "<html><body><h1>Hello Best Bike App!</h1></body></html>\n"
(venv) root@ubansinode1:/myworkspace/BestBikeApp#
(venv) root@ubansinode1:/myworkspace/BestBikeApp# pip freeze > requirements.txt

(venv) root@ubansinode1:/myworkspace/BestBikeApp# cat requirements.txt
blinker==1.6.2
click==8.1.3
Flask==2.3.2
importlib-metadata==6.7.0
itsdangerous==2.1.2
Jinja2==3.1.2
MarkupSafe==2.1.3
Werkzeug==2.3.6
zipp==3.15.0
(venv) root@ubansinode1:/myworkspace/BestBikeApp#
(venv) root@ubansinode1:/myworkspace/BestBikeApp# export FLASK_APP=application.py
(venv) root@ubansinode1:/myworkspace/BestBikeApp# flask run
 * Serving Flask app 'application.py'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://127.0.0.1:5000
Press CTRL+C to quit
127.0.0.1 - - [29/Jun/2023 22:20:46] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [29/Jun/2023 22:20:46] "GET /favicon.ico HTTP/1.1" 404 -
(venv) root@ubansinode1:/myworkspace/BestBikeApp#

(venv) root@ubansinode1:/myworkspace/BestBikeApp# cat export.sh
export APPNAME=$(az webapp list --query [0].name --output tsv)
export APPRG=$(az webapp list --query [0].resourceGroup --output tsv)
export APPPLAN=$(az appservice plan list --query [0].name --output tsv)
export APPSKU=$(az appservice plan list --query [0].sku.name --output tsv)
export APPLOCATION=$(az appservice plan list --query [0].location --output tsv)

(venv) root@ubansinode1:/myworkspace/BestBikeApp# bash -x export.sh
++ az webapp list --query '[0].name' --output tsv
+ export APPNAME=mypythonapp123
+ APPNAME=mypythonapp123
++ az webapp list --query '[0].resourceGroup' --output tsv
+ export APPRG=learn-70a33bc5-e0b5-41a0-a930-d8261aba71ce
+ APPRG=learn-70a33bc5-e0b5-41a0-a930-d8261aba71ce
++ az appservice plan list --query '[0].name' --output tsv
+ export APPPLAN=ASP-learn70a33bc5e0b541a0a930d8261a-ba0c
+ APPPLAN=ASP-learn70a33bc5e0b541a0a930d8261a-ba0c
++ az appservice plan list --query '[0].sku.name' --output tsv
+ export APPSKU=F1
+ APPSKU=F1
++ az appservice plan list --query '[0].location' --output tsv
+ export 'APPLOCATION=East US'
+ APPLOCATION='East US'
(venv) root@ubansinode1:/myworkspace/BestBikeApp#
```
## Push to Azure
```
(venv) root@ubansinode1:/myworkspace/BestBikeApp# az webapp up --name $APPNAME --resource-group $APPRG --plan $APPPLAN --sku $APPSKU --location "$APPLOCATION"
Webapp 'mypythonapp123' already exists. The command will deploy contents to the existing app.
Creating AppServicePlan 'ASP-learn70a33bc5e0b541a0a930d8261a-ba0c' ...
Creating zip with contents of dir /myworkspace/BestBikeApp ...
Getting scm site credentials for zip deployment
Starting zip deployment. This operation can take a while to complete ...
Deployment endpoint responded with status code 202
You can launch the app at http://mypythonapp123.azurewebsites.net
Setting 'az webapp up' default arguments for current directory. Manage defaults with 'az configure --scope local'
--resource-group/-g default: learn-70a33bc5-e0b5-41a0-a930-d8261aba71ce
--sku default: F1
--plan/-p default: ASP-learn70a33bc5e0b541a0a930d8261a-ba0c
--location/-l default: eastus
--name/-n default: mypythonapp123
{
  "URL": "http://mypythonapp123.azurewebsites.net",
  "appserviceplan": "ASP-learn70a33bc5e0b541a0a930d8261a-ba0c",
  "location": "eastus",
  "name": "mypythonapp123",
  "os": "Linux",
  "resourcegroup": "learn-70a33bc5-e0b5-41a0-a930-d8261aba71ce",
  "runtime_version": "python|3.10",
  "runtime_version_detected": "-",
  "sku": "FREE",
  "src_path": "//myworkspace//BestBikeApp"
}

```
