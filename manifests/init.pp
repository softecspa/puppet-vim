# = Class Vim
#
# Manage Vim package and our system-wide setup:
# - /etc/vim/vimrc.local
# - /etc/vim/autoload/pathogen.vim to manage bundles of features
# - /etc/vim/bundle/ where we put system-wide bundles, typically
#   with a git clone from the official repo
class vim
{
  package { 'vim':
    name    => $::lsbdistcodename ? {
      "hardy" => "vim-full",
      default => "vim",
    },
    ensure  => installed,
  }

  file { '/etc/vim/vimrc.local':
    source  => 'puppet:///modules/vim/conf/vimrc.local',
    owner   => 'root',
    group   => 'admin',
    mode    => '664',
    require => Package['vim'],
  }

  File {
    require => File['/etc/vim/vimrc.local'],
    owner   => root,
    group   => admin,
    mode  => '664',
  }

  # Rimuove vecchie customizzazioni
  file { '/root/.vimrc':  ensure  => absent }
  file { '/root/.vim':    ensure  => absent, recurse => true, force => true }

  file { '/usr/share/vim/vimcurrent/syntax/puppet.vim':
    source  => 'puppet:///modules/vim/syntax/puppet.vim',
  }
  
  file { '/usr/share/vim/vimcurrent/syntax/wiki.vim':
    source  => 'puppet:///modules/vim/syntax/wiki.vim',
  }
  
  file { '/usr/share/vim/vimcurrent/syntax/vcl.vim':
    source  => 'puppet:///modules/vim/syntax/vcl.vim',
  }

  # Pathogen: Manage your 'runtimepath' with ease. In practical
  # terms, pathogen.vim makes it super easy to install plugins
  # and runtime files in their own private directories.
  $vim_dirs = [
    '/etc/vim/bundle',
    '/etc/vim/autoload',
  ]

  file { $vim_dirs:
    ensure  => directory,
  }

  file { '/etc/vim/autoload/pathogen.vim':
    source      => 'puppet:///modules/vim/autoload/pathogen.vim',
    require     => File[ $vim_dirs ],
  }

  git::clone { 'puppet-vim-bundle':
    url         => 'github.com/rodjek/vim-puppet.git',
    path        => '/etc/vim/bundle/puppet',
    require     => File[ $vim_dirs ],
  }

  git::clone { 'syntastic-vim-bundle':
    url         => 'github.com/scrooloose/syntastic.git',
    path        => '/etc/vim/bundle/syntastic',
    require     => File[ $vim_dirs ],
  }
}
