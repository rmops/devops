file { "/etc/sudoers.d/90-cloudimg-ubuntu":
        mode=>0440,
        source => "puppet:///modules/systembase/90-cloudimg-ubuntu",
        owner =>"root",
        group =>"root",
        }



user { "henry":
        ensure=>present,
        shell=>"/bin/bash",
        home => "/home/henry",
        }
exec { "create-henry-home":
        command => "/bin/cp -R /etc/skel /home/henry&& /bin/chown -R henry:henry /home/henry ",
        creates =>"/home/henry",
        require => User[henry],
}

ssh_authorized_key { "henry-key":
        ensure=>present,
        type =>"ssh-dss",
        name=>"henry",
        key=> "AAAAB3NzaC1kc3MAAACBAKMydZ88bSnN9aDbUnc2G54pbaCQnheQ7obYmKMNGRzp5iQjWqYuYTdp/TXSvGMDPAtiPRIj8odmLOvtxdX7IxNZHxyjkpJAo444URng5Mv+lT0ApzPf7cwnb0/l87az8OgpKLicyK7Iiv0AOr+VD96OXeb557dTriVZl2Pjfc3hAAAAFQC2WoWiD60hagsqocWdUIZJrQskhwAAAIAOFFJIVaUdC8t2EywG1XdNEwqqLuiBOtg+cO7JnNP83/ZTwqsbGiFjVzDfslvNpSI4XP9hbdr4CtcBgMt0sAmr53ObUUrknLhJoWPQh3urCqdlJUYX/pnDqaFTJBdA9/7fCgVtNrAzFf+6nZU/XjOUWRhzTMWq7bi1IHrUOsjRsQAAAIBRyzF5JiqbKj4vQspLvTO6dfG6psw7I3lJY+6BUYbjEvaJFxZo3O6BVdNF8NSpULi8cDh6/4ibk8QFMSyIH0vBW7Bys1UuerrSv+DUt5f35h077f5M36PzqlN8dgtaT3nPtU++QggmTiYaXMasD005XKXSGho5kjmOO7c46Aas2g==",
        target=>"/home/henry/.ssh/authorized_keys",
        user=>'henry',
 require => Exec["create-henry-home"],
}

