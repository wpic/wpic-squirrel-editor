load('jjunit.js');

var SimpleDateFormat = Java.type("java.text.SimpleDateFormat");
var Date = Java.type("java.util.Date");

var dateFormat = new SimpleDateFormat('yyyy-MM-dd hh:mm');
var scripts = [
    {
        name: 'sample.js',
        content: '',
        temp: 'function(a) {}',
        committed: false,
        lastEdit: dateFormat.format(new Date())
    }
];

var handlers = [
    {
        method: 'GET',
        path: '/rest/scripts',
        handler: function(param) {
            return scripts;
        }
    },
    {
        method: 'GET',
        path: '/rest/scripts/$name',
        handler: function(param) {
            for each (script in scripts) {
                if (script.name == param.name) {
                    return script;
                }
            }
        }
    },
    {
        method: 'POST',
        path: '/rest/scripts/$name',
        accept: 'application/json',
        handler: function(param, data) {
            var script = {
                name: param.name,
                committed: false,
                temp: data,
                lastEdit: dateFormat.format(new Date())
            };
            for each (s in scripts) {
                if (s.name == param.name) {
                    throw "Script already exist: " + param.name;
                }
            }
            scripts.push(script);
            return script;
        }
    },
    {
        method: 'PUT',
        path: '/rest/scripts/commit/$name',
        handler: function(param) {
            for each (script in scripts) {
                if (script.name == param.name) {
                    script.content = script.temp;
                    script.lastEdit = dateFormat.format(new Date());
                    script.committed = true;
                    return script;
                }
            }
        }
    },
    {
        method: 'PUT',
        path: '/rest/scripts/rename/$from/$to',
        handler: function(param) {
            print('here1')
            for each (script in scripts) {
                if (script.name == param.from) {
                    script.name = param.to;
                    return script;
                }
            }
        }
    },
    {
        method: 'PUT',
        path: '/rest/scripts/$name',
        accept: 'text/plain',
        handler: function(param, data) {
            print('here2')
            for each (script in scripts) {
                if (script.name == param.name) {
                    script.temp = data;
                    script.lastEdit = dateFormat.format(new Date());
                    script.committed = false;
                    return script;
                }
            }
        }
    },
    {
        method: 'DELETE',
        path: '/rest/scripts/$name',
        handler: function(param) {
            for (var i = 0; i < scripts.length; i++) {
                if (scripts[i].name == param.name) {
                    scripts.splice(i, 1);
                    return scripts;
                }
            }
        }
    }
];

var jjunit = new JJUnit('.', handlers);
jjunit.start();


