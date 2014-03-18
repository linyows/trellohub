Trellohub
=========

Trellohub is uniform task management by synchronizing the github issues and trello cards.

[![Gem Version](https://badge.fury.io/rb/trellohub.png)][gem]
[![Build Status](https://secure.travis-ci.org/linyows/trellohub.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/linyows/trellohub.png?travis)][gemnasium]
[![Code Climate](https://codeclimate.com/github/linyows/trellohub.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/linyows/trellohub/badge.png?branch=master)][coveralls]

[gem]: https://rubygems.org/gems/trellohub
[travis]: http://travis-ci.org/linyows/trellohub
[gemnasium]: https://gemnasium.com/linyows/trellohub
[codeclimate]: https://codeclimate.com/github/linyows/trellohub
[coveralls]: https://coveralls.io/r/linyows/trellohub

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'trellohub'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install trellohub
```

Usage
-----

```sh
$ cp boards/example.yml boards/your_board_name.yml
```

edit `boards/your_board_name.yml`:

```yml
```

Synchronizing
-------------

GitHub Issues     | Trello Cards   | Description
-------------     | ------------   | -----------
status changes    | status changes | open, closed : create, delete
milestone changes | status changes | when setted milestones
labels change     | list changes   | label: todo => list: To Do
title changes     | title changes  | card title: 'repo_name#issue_number title'
asignee changes   | member changes | first member is issue assignee

Contributing
------------

1. Fork it ( http://github.com/linyows/trellohub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Authors
-------

- [linyows](https://github.com/linyows)

License
-------

The MIT License (MIT)
