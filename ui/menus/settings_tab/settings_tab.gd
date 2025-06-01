extends Control


## The [color= light_blue].tres[/color] file that contains the settings configurations
@export var settings_config_file: Resource


func _ready():
	settings("load", settings_config_file)


func _exit_tree():
	settings("save", settings_config_file)


func settings(method: String = "", resource_file: Resource = null) -> void:
	if method == "load":
		$SettingsHBox/VolumeMargin/VolumeVBox/Music/MusicSlider.value = resource_file.volume_music
		$SettingsHBox/VolumeMargin/VolumeVBox/GameSFX/GameSFXSlider.value = resource_file.volume_game_sfx
		$SettingsHBox/VolumeMargin/VolumeVBox/MenuSFX/MenuSFXSlider.value = resource_file.volume_menu_sfx
		$SettingsHBox/DisplayMargin/DisplayVBox/OptionButton.selected = resource_file.display
	
	if method == "save":
		resource_file.volume_music = $SettingsHBox/VolumeMargin/VolumeVBox/Music/MusicSlider.value
		resource_file.volume_game_sfx = $SettingsHBox/VolumeMargin/VolumeVBox/GameSFX/GameSFXSlider.value
		resource_file.volume_menu_sfx = $SettingsHBox/VolumeMargin/VolumeVBox/MenuSFX/MenuSFXSlider.value
		resource_file.display = $SettingsHBox/DisplayMargin/DisplayVBox/OptionButton.selected
		ResourceSaver.save(resource_file, "res://resources/settings_config/settings_config.tres")
