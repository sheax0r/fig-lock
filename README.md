# Fig::Lock

Generates fig.lock files based on fig.yml files.
Gets the latest versions of all images defined in a
fig.yml file, rewrites them to include the specific tags 
of those versions, generates a fig.lock file.

## Installation

Add this line to your application's Gemfile:

    gem 'fig-lock'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fig-lock

## Usage

fig-lock produces fig.lock files from fig.yml files, locking images to specific versions.
eg:

fig.yml:
```
---
image: ubuntu
image: my.docker-registry.com/repo/myimage
```

resulting fig.lock:
```
---
image: ubuntu:14.04
image: my.docker-registry.com/repo/myimage:0.0.1
```

Currently, fig-lock only works properly with images that have been explicitly tagged. However, the next 
iteration should use hashes if tags are not available.

### Install
The *install* command uses docker to retrieve all images
defined in fig.lock. If no fig.lock file exists, one will
be generated by invoking the *update* command.
```
  fig-lock install </path/to/fig.yml>
```

### Update
The *update* command uses docker to retrieve the latest versions
of all images defined in the fig.yml file and generates/updates
a corresponding fig.lock file in the same directory as the fig.yml file,
which uses specific version tags for these images.
```
  fig-lock update </path/to/fig.yml>
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/fig-lock/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
