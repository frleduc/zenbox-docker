FROM zenika/alpine-node:8

WORKDIR /data

COPY package.json package.json
RUN npm install

#Mandatory to display the slides... WTF????
COPY .git .git
COPY Slides Slides

COPY Gruntfile.js Gruntfile.js

ENTRYPOINT ["./node_modules/.bin/grunt"]
