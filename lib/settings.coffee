fs = require 'fs'
events = require 'events'
require 'coffee-react/register'
SettingsView = require('./settings-view').SettingsView
SettingsComponent = require('./settings-view').SettingsComponent

module.exports =
class Settings
  constructor: (@cantik) ->
    events.EventEmitter.call(this)

    @configPath = "#{@cantik.app.getPath 'userData'}/config.json"

    @settings = @loadSettings()

    @cantik.pluginManager.plugins.sidebar.addLink('Settings', 'Main', @show.bind(@), null, false)

  activate: (state) ->

  show: (state) ->
    @settingsView = new SettingsView(@)

  deactivate: ->
    if @settingsView?
      @settingsView.destroy()

  serialize: ->
    settingsViewState: @settingsView.serialize()

  addSetting: (pluginName, settingName, settingType, settingDefault) ->
    if not @settings[pluginName]?
      @settings[pluginName] = {}

    if not @settings[pluginName][settingName]?
      @settings[pluginName][settingName] = {value: settingDefault, type: settingType}
      do @saveSettings
      settingDefault
    else
      @settings[pluginName][settingName].value

  getSetting: (pluginName, settingName) ->
    @settings[pluginName]?[settingName]?.value

  setSetting: (pluginName, settingName, value) ->
    @settings[pluginName]?[settingName]?.value = value
    @emit("#{pluginName}-#{settingName}-change", value)
    do @saveSettings

  setSettings: (settings) ->
    oldSettings = JSON.parse(JSON.stringify(@settings))
    @settings = JSON.parse(JSON.stringify(settings))

    # Emit events
    for pluginName, pluginSettings of settings
      for settingName, settingParam of pluginSettings
        if settingParam.value != oldSettings[pluginName][settingName].value
          try
            @emit("#{pluginName}-#{settingName}-change", settingParam.value)
          catch error

    do @saveSettings

  loadSettings: ->
    if fs.existsSync(@configPath)
      JSON.parse fs.readFileSync(@configPath)
    else
      {}

  saveSettings: ->
    fs.writeFile(@configPath, JSON.stringify(@settings))

Settings.prototype.__proto__ = events.EventEmitter.prototype
