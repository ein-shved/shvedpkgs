#!/usr/bin/env python

import os
import sys
from os import environ, path
import json
from PyQt5.QtWidgets import QApplication, QWidget
from PyQt5.QtWidgets import QLayout, QVBoxLayout, QHBoxLayout
from PyQt5.QtWidgets import QTableWidget, QTableWidgetItem, QAbstractItemView
from PyQt5.QtWidgets import QPushButton, QFileDialog


dbpath = path.join(environ.get("HOME", "/tmp"), ".config/vim-ide-db.json")


def saveDb(db):
    dbfile = open(dbpath, "w")
    json.dump(db, dbfile, indent=4)
    dbfile.close()


def runEditor(db, req):
    editor = "gvim"
    name = None
    project = None

    for n, (k, v) in enumerate(db):
        if k == req:
            project = v
            name = k
            del db[n]
            break

    if name is None or project is None:
        if path.isdir(req):
            name = path.basename(path.abspath(req))
            project = req
        else:
            print("Can not open {} project".format(req))
            exit(1)
    db.insert(0, (name, project))

    saveDb(db)

    os.chdir(project)
    os.execlp(editor, editor)


def runSelector(db):
    app = QApplication([])
    window = QWidget()
    layout = QVBoxLayout()
    blayout = QHBoxLayout()
    table = QTableWidget(len(db), 2)
    edit = None

    def on_selected(item):
        row = table.row(item)
        item = table.item(row, 0)
        req = item.text()
        runEditor(db, req)

    for n, (k, v) in enumerate(db):
        table.setItem(n, 0, QTableWidgetItem(k))
        table.setItem(n, 1, QTableWidgetItem(v))
    table.itemDoubleClicked.connect(on_selected)
    table.resizeColumnsToContents()
    table.setFixedWidth(table.columnWidth(0) + table.columnWidth(1) + 2)
    table.horizontalHeader().hide()
    table.verticalHeader().hide()
    table.setSelectionBehavior(QAbstractItemView.SelectRows)
    table.setEditTriggers(QAbstractItemView.NoEditTriggers)
    layout.addWidget(table)

    def on_open():
        d = QFileDialog.getExistingDirectory(caption="Select Project",
                                             options=QFileDialog.ShowDirsOnly)
        if len(d) > 0:
            runEditor(db, d)

    def on_edit():
        nonlocal edit
        row = table.currentRow()
        item = table.item(row, 0)
        edit = {"name": item.text(), "obj": item}
        table.editItem(item)

    def on_edited(item):
        nonlocal edit
        if edit is None:
            return
        old = edit["name"]
        new = item.text()
        for n, (k, v) in enumerate(db):
            if old == k:
                del db[n]
                db.insert(n, (new, v))
                break
        edit = None
        saveDb(db)

    def on_remove():
        row = table.currentRow()
        item = table.item(row, 0)
        key = item.text()
        table.removeRow(row)
        for n, (k, v) in enumerate(db):
            if key == k:
                del db[n]
                break
        saveDb(db)

    table.itemChanged.connect(on_edited)

    button = QPushButton("Open Another Project")
    button.clicked.connect(on_open)
    blayout.addWidget(button)

    editButton = QPushButton("Rename")
    editButton.clicked.connect(on_edit)
    blayout.addWidget(editButton)

    removeButton = QPushButton("Remove")
    removeButton.clicked.connect(on_remove)
    blayout.addWidget(removeButton)

    layout.addLayout(blayout)

    layout.setSizeConstraint(QLayout.SetFixedSize)
    window.setLayout(layout)
    window.show()
    app.exec()


try:
    dbfile = open(dbpath)
    db = json.load(dbfile)
    dbfile.close()
except(FileNotFoundError):
    db = []

if type(db) is dict:
    db_l = []
    for k, v in db.items():
        db_l.append((k, v))
    db = db_l

if len(sys.argv) > 1:
    req = sys.argv[1]
    runEditor(db, req)
else:
    runSelector(db)
