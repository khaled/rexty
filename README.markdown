Introduction
============

Rexty is a plugin that aims to assist in the development of Rails back ends for Ext JS applications.

At the moment, the functionality offered is fairly minimal.

Example
========

Controller code: 

    class CompanyController < ApplicationController
      renders_ext_tree :companies, :roots => lambda { Company.all } do
        node :company, :text => :name, :children => :projects
        node :project, :text => :name, :children => :tasks
        node :task, :text => :name
      end
    end

Javascript code:

      var tree = new Ext.tree.TreePanel({
        loader: new Ext.tree.TreeLoader({ 
          dataUrl: "/company/companies_tree_data" 
        }),
        root: new Ext.tree.AsyncTreeNode({ 
          id: "root", 
          text: "Root", 
          expanded: true
        }),
        rootVisible: false,
        height: 300,
        width: 200,
        el: "tree"
      });
      tree.render();


Copyright (c) 2008 Khaled Agrama, released under the MIT license