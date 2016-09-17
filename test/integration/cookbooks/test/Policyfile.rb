name 'test'
default_source :supermarket
cookbook 'test', path: './'
run_list 'test::default'
named_run_list 'sftp', 'test::default'
named_run_list 'win', 'test::default'
named_run_list 'ssh', 'test::search'
