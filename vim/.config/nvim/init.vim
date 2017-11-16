if &compatible
  set nocompatible
endif
set runtimepath+=~/.vim/bundles/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.vim/bundles/')
  call dein#begin('~/.vim/bundles/')

  call dein#add('~/.vim/bundles/repos/github.com/Shougo/dein.vim')
  call dein#add('Shougo/neocomplete.vim')
  call dein#add('w0rp/ale')


  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable


let mapleader = " "
let maplocalleader = " "

set incsearch

syntax on

set background=dark
set termguicolors

set noerrorbells
set visualbell

set colorcolumn=+1

set hlsearch
set ignorecase

set tabstop=2
set shiftwidth=2
set expandtab
set si


