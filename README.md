Trellohub (trello cards x github issues)
========================================

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

<p align=center><img src="http://octodex.github.com/images/forktocat.jpg" width=500></p>

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
board_id: 531c1a3524127e**********
repositories:
  - full_name: organization/project_one
    milestone: Stable Version
  - full_name: organization/project_two
    milestone: Ver2
  - full_name: organization/project_three
    milestone: New Feature
lists:
  - name: Backlog
    default: true
  - name: To Do
    issue_label: to do
  - name: Doing
    issue_label: doing
  - name: Done
    issue_label: done
  - name: Recent Closed
    issue_closed_at: '>= Time.now.utc -60*60*24*7'
trello_application_key: 429452e37b7e********************
trello_application_token: dc71944d87340616f03a7647****************************************
github_access_token: e17e1c6caa******************************
```

```sh
$ env CONFIG_PATH=~/trellohub/boards/your_board_name.yml trellohub
```

Synchronizing
-------------

GitHub Issues                | Trello Cards               | Description
-------------                | ------------               | -----------
Status(open, closed) changes | Closed(true false) changes | All created by a token user When trellohub creates the issue.
Milestone changes            | Status changes             | If setted milestones
Labels change                | List changes               | e.g. The "todo" label => The "To Do" list
Title changes                | Title changes              | Card title format is 'repo_name#issue_number title'
Asignee changes              | Member changes             | First member is issue assignee.

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
