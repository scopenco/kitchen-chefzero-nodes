# Kitchen::ChefZeroNodes

Provisioner `chef_zero_nodes` extends `chef_zero` by adding one more step in the end of converge - it downloads the resulted node
JSON object to the `nodes_path` on the host machine after successful converge. It allows you to use this node object for searches while converging another
Test Kitchen suites. So, you can use actual node attributes like ipaddress/fqdn to communicate nodes with each other.

For example, 'web' node need to search 'db' node ip.
In `chef_zero` we have to create mock in node_path for this search. `chef_zero_nodes` will save mock automatically after 'db' successful converge.

## Requirements

* ChefDK 0.12.0+
* Test Kitchen 1.10+

## Supports

* Linux
* Windows 2012 RC2

## Installation

```
gem install kitchen-chefzero-nodes
```

## Configuration

Use `chef_zero_nodes` instead of `chef_zero` for the kitchen provisioner name.

```
provisioner:
  name: chef_zero_nodes
```

## Development

* Source hosted at [GitHub](https://github.com/scopenco/kitchen-chefzero-nodes)
* Report issues/questions/feature requests on [GitHub Issues](https://github.com/scopenco/kitchen-chefzero-nodes/issues)

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Testing

1. Run `bundle install`
2. Run `rake` for unit testing

## Authors

Created and maintained by [Andrei Skopenko][author] (<andrei@skopenko.net>)

## License

Apache 2.0


[author]:           https://github.com/scopenco
[issues]:           https://github.com/scopenco/kitchen-policyfile-nodes/issues
[license]:          https://github.com/scopenco/kitchen-policyfile-nodes/blob/master/LICENSE
[repo]:             https://github.com/scopenco/kitchen-policyfile-nodes
[driver_usage]:     http://docs.kitchen-ci.org/drivers/usage
[chef_omnibus_dl]:  http://www.getchef.com/chef/install/
