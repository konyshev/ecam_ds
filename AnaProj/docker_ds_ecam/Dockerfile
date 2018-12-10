FROM jupyter/scipy-notebook:latest

WORKDIR /code
ADD requirements.cfg /code/
RUN pip install --upgrade pip \ 
    && pip install -r requirements.cfg \
    && jupyter nbextensions_configurator enable --user \
    && jupyter contrib nbextensions install --sys-prefix --skip-running-check
ADD . /code/