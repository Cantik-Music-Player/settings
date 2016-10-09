React = require('react')
ReactDOM = require('react-dom')

module.exports.SettingsComponent =
class SettingsComponent extends React.Component
  constructor: (props) ->
    super props

    @state = {display: 'block'}

    @settings = JSON.parse(JSON.stringify(props.settings.settings))  # Copy object

  hideSettings: ->
    @setState display: 'none'

  generateField: (name, value, type, plugin) ->
    <div key={"{#{name}-#{plugin}}"}>
      {@generateTextInput(name, value, plugin) if type is 'text'}
      {@generatePasswordInput(name, value, plugin) if type is 'password'}
      {@generateFileInput(name, value, plugin) if type is 'file'}
    </div>

  setSetting: (plugin, name, e) ->
    @settings[plugin][name].value = e.target.value

  generateTextInput: (name, value, plugin) ->
    <div className="form-group">
      <label htmlFor={name} className="col-md-2 control-label">{name}</label>
      <div className="col-md-10">
        <input type="text" className="form-control" id={name} defaultValue={value}
        placeholder={name} onChange={@setSetting.bind(@, plugin, name)} />
      </div>
    </div>

  generatePasswordInput: (name, value, plugin) ->
    <div className="form-group">
      <label htmlFor={name} className="col-md-2 control-label">{name}</label>
      <div className="col-md-10">
        <input type="password" className="form-control" id={name} defaultValue={value}
        placeholder={name} onChange={@setSetting.bind(@, plugin, name)} />
      </div>
    </div>

  generateFileInput: (name, value, plugin) ->
    <div className="form-group">
      <label htmlFor={name} className="col-md-2 control-label">{name}</label>
      <div className="col-md-10">
        <input type="text" className="form-control" id={name} defaultValue={value}
        placeholder={name} onSelect={@openFileChooser.bind(@, plugin, name)} />
      </div>
    </div>

  openFileChooser: (plugin, name, e) ->
    if not @dialog? or not @dialog  # Do not show dialog when getting back focus after closing this dialog
      @dialog = true
      path = dialog.showOpenDialog({properties: [ 'openFile', 'openDirectory', 'multiSelections']})[0]
      e.target.value = path if path?
      @settings[plugin][name].value = path if path?
    else
      @dialog = false

  saveSettings: (e) ->
    @props.settings.setSettings @settings
    do @hideSettings

    # Stop event propagation
    if e?
      e.preventDefault()
      e.stopPropagation()

  render: ->
    <div className="modal" style={{display: @state.display}}>
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <button type="button" className="close" data-dismiss="modal" aria-hidden="true" onClick={@hideSettings.bind(@)}>×</button>
            <h4 className="modal-title">Settings</h4>
          </div>
          <div className="modal-body">
            <form onSubmit={@saveSettings.bind(@)}>
              {<fieldset>
                <legend>{plugin}</legend>
                {@generateField(name, settingDetails.value, settingDetails.type, plugin) for name, settingDetails of settings}
              </fieldset> for plugin, settings of @props.settings.settings}
            </form>
          </div>
          <div className="modal-footer">
            <button type="button" className="btn btn-default" onClick={@hideSettings.bind(@)}>Close</button>
            <button type="button" className="btn btn-primary" onClick={@saveSettings.bind(@)}>Save changes</button>
          </div>
        </div>
      </div>
    </div>

module.exports.SettingsView =
class SettingsView
  constructor: (@settings) ->
    @element = document.createElement('div')
    ReactDOM.render(
      <SettingsComponent settings=@settings />,
      @element
    )
    document.getElementsByTagName('body')[0].appendChild(@element);

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
