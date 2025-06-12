class_name InventoryBag extends Node

@export var agent: BaseCharacter
#@export var inventoryUI: InventoryUI

signal addItem(NameOrItem, amount: int)
signal removeItem(NameOrItem, amount: int)
signal createItem(itemName: String)
signal useItem(itemName:String)
@warning_ignore("unused_signal")
signal updateInventory

var inventoryBag: Dictionary = {}
var equippedItems: Dictionary = {
	"Head": null,
	"Body": null,
	"Legs": null,
	"Feet": null,
	"Off Hand": null,
	"Main Hand": null,
	"Bag": null
}

func _ready() -> void:
	addItem.connect(AddItemToBag)
	removeItem.connect(RemoveItemFromBag)
	useItem.connect(UseItem)
	createItem.connect(CreateItem)

func CreateItem(itemName: String) -> ItemData:
	# Try to find the item in all categories
	var categories = ["Currency", "Consumables", "Gear", "Mob Drops"]
	for category in categories:
		if GameManager.gameData["Items"].has(category) and GameManager.gameData["Items"][category].has(itemName):
			var itemPath = GameManager.gameData["Items"][category][itemName]["path"]
			var itemResource = ResourceLoader.load(itemPath)
			if itemResource == null:
				push_error("Error: Item resource not found: " + itemPath)
				return null

			return itemResource.duplicate()

	push_error("Error: Item name not found in gameData: " + itemName)
	return null

func AddItemToBag(itemNameOrObject, amount: int):
	var item

	if itemNameOrObject is String:
		# Create the item from the name using the updated CreateItem function
		# which handles the nested structure
		item = CreateItem(itemNameOrObject)
		if item == null:
			return null
	else:
		# We received an actual item object
		item = itemNameOrObject
	
	# Handle stackable items
	if item and item.stackable:
		var remainingAmount = amount
		
		# Try to add to existing stacks first
		for itemID in inventoryBag:
			var existingItem = inventoryBag[itemID]
			if existingItem.itemName == item.itemName:
				var spaceInStack = existingItem.maxAmount - existingItem.amount
				var amountToAdd = min(remainingAmount, spaceInStack)
				existingItem.amount += amountToAdd
				remainingAmount -= amountToAdd
				
				if remainingAmount == 0:
					break
		
		# Create new entries if needed
		while remainingAmount > 0:
			var newItem = item.duplicate()
			newItem.amount = min(remainingAmount, item.maxAmount)
			var newID = str(Time.get_ticks_msec()) + "_" + item.itemName
			inventoryBag[newID] = newItem
			remainingAmount -= newItem.amount
	else:
		# For non-stackable items, just add directly
		var newID = str(Time.get_ticks_msec()) + "_" + item.itemName
		inventoryBag[newID] = item

	# Update the UI
	emit_signal("updateInventory")

	return item

func ConsolidateInventory() -> void:
	var itemsToRemove = []
	for itemID in inventoryBag:
		var currentItem = inventoryBag[itemID]
		if currentItem.stackable and currentItem.amount < currentItem.maxAmount:
			for otherID in inventoryBag:
				if itemID != otherID and inventoryBag[otherID].itemName == currentItem.itemName:
					var otherItem = inventoryBag[otherID]
					var spaceInStack = currentItem.maxAmount - currentItem.amount
					var amountToMove = min(spaceInStack, otherItem.amount)
					
					currentItem.amount += amountToMove
					otherItem.amount -= amountToMove
					
					if otherItem.amount <= 0:
						itemsToRemove.append(otherID)
	
	for id in itemsToRemove:
		inventoryBag.erase(id)

func RemoveItemFromBag(itemName: String, amount: int) -> void:
	var itemKey = FindItemKey(itemName)
	
	if itemKey != null:
		var item = inventoryBag[itemKey]
		
		if item.stackable:
			if amount >= item.amount:
				inventoryBag.erase(itemKey)
			else:
				item.amount -= amount
		else:
			inventoryBag.erase(itemKey)
	

		emit_signal("updateInventory")

func UseItem(itemName: String):
	var itemID = FindItemKey(itemName)
	if itemID == null:
		return

	var item = inventoryBag[itemID]
	
	var success = item.ApplyEffect(agent)
	
	if success:
		if item.stackable:
			item.amount -= 1
			if item.amount <= 0:
				inventoryBag.erase(itemID)
		else:
			inventoryBag.erase(itemID)
			
		emit_signal("updateInventory")
	
	return success

func FindItemKey(itemName: String):
	for itemID in inventoryBag:
		if inventoryBag[itemID].itemName == itemName:
			return itemID
	return null

func CountItems(itemName: String) -> int:
	var totalQuantity = 0
	
	for item_id in inventoryBag:
		var item = inventoryBag[item_id]
		if item != null and item.itemName == itemName:
			if item.stackable:
				totalQuantity += item.amount
			else:
				totalQuantity += 1
	
	return totalQuantity
