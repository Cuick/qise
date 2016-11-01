{application, api_app,
[{description,"QISE api Gate"},
 {vsn,"1.0"},
 {modules,[api_app,api_listener,api_listener_sup,api_acceptor_sup,api_acceptor,api_client_sup,api_client]},
 {registered,[api_listener,api_listener_sup,api_acceptor_sup]},
 {applications,[kernel,stdlib]},
 {mod,{api_app,[]}}
 ]
}.
