myLooter = {};

  


myLooter.myInventory = {};
myLooter.myInventory.__index = myLooter.myInventory;
myLooter.myLootbox = {};
myLooter.myLootbox.__index = myLooter.myLootbox;



function myLooter.BreakLink(link)
    -- code ganked from Tooltip.lua
    if (type(link) == number) then return link,0,0,0,"",0,0,0,0,0 end
    if (type(link) ~= 'string') then return end
    local itemID, enchant, gemSlot1, gemSlot2, gemSlot3, gemBonus, randomProp, uniqID, name = link:match("|Hitem:(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+)|h%[(.-)%]|h")
    local randomFactor = 0
    randomProp = tonumber(randomProp) or 0
    uniqID = tonumber(uniqID) or 0
    if (randomProp < 0 and uniqID < 0) then
        randomFactor = bit.band(uniqID, 65535)
    end
    return tonumber(itemID) or 0, tonumber(randomProp) or 0, tonumber(enchant) or 0, tonumber(uniqID) or 0, tostring(name), tonumber(gemSlot1) or 0, tonumber(gemSlot2) or 0, tonumber(gemSlot3) or 0, tonumber(gemBonus) or 0, randomFactor
  end
  
function myLooter.returnValue(itemLink)
    local itemID, randomProperty, enchantment, uniqueID, itemName, gemSlot1, gemSlot2, gemSlot3, gemSlotBonus = myLooter.BreakLink(itemLink);
    local sellprice = Auctioneer.API.GetVendorSellPrice(itemID);
    return sellprice;
end

function myLooter.returnQuality(link)
    -- regular expression and original code ganked from Tooltip.lua
    if (not link) then return end
    local color = link:match("(|c%x+)|Hitem:%p?%d+:%p?%d+:%p?%d+:%p?%d+:%p?%d+:%p?%d+:%p?%d+:%p?%d+|h%[.-%]|h|r")
    if (color) then
        for i = 0, 6 do
            local _, _, _, hex = GetItemQualityColor(i)
            if color == hex then
                return i
            end
        end
    end
    return -1
end
  
function myLooter.isTrash(link)
    if myLooter.returnQuality(link) == 0 then
        return 1;
    end
    return nil;
end
 
  
function myLooter:main() 
    while true do 
        --DEFAULT_CHAT_FRAME:AddMessage("starting", 0.0, 1.0, 0.0);
        local msg = string.format("myLooter.lastevent = %s", myLooter.lastevent);
        --DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0);
        if myLooter.lastevent == "LOOT_OPENED" then 
            --DEFAULT_CHAT_FRAME:AddMessage("yikes", 0.0, 1.0, 0.0);
            local KEEPFREESLOTS = 1;
            local lootbox = myLooter.myLootbox:new();
            local lootSlots = lootbox:lootSlots();
            local cheapestLootTrashSlot, cheapestLootTrashValue = lootbox:cheapestLootTrash();
            local inventory = myLooter.myInventory:new();
            local totalSlots = inventory:totalSlots();
            local usedSlots = inventory:usedSlots();
            local freeSlots = inventory:freeSlots();
            local cheapestTrashBag, cheapestTrashSlot, cheapestTrashValue = inventory:cheapestTrash();
            local cheapestTrash = GetContainerItemLink(cheapestTrashBag,cheapestTrashSlot);
            local lootbox = myLooter.myLootbox:new();
            local lootSlots = lootbox:lootSlots();
            local cheapestLootTrashSlot, cheapestLootTrashValue = lootbox:cheapestLootTrash();
            --local availableBagSlots = myLooter.AvailableBagSlots();
            local margin = lootSlots - freeSlots + KEEPFREESLOTS;   
            msg1 = string.format("Total Slots = %d", totalSlots);
            msg2 = string.format("Used Slots  = %d", usedSlots);
            msg3 = string.format("Free Slots  = %d", freeSlots);
            msg4 = string.format("Cheapest Trash = %s", cheapestTrash);
            msg5 = string.format("Cheapest Trash Value = %d", cheapestTrashValue);
            msg6 = string.format("Margin = %d", margin);    
            --DEFAULT_CHAT_FRAME:AddMessage(msg1, 0.0, 1.0, 0.0);
            --DEFAULT_CHAT_FRAME:AddMessage(msg2, 0.0, 1.0, 0.0);
            --DEFAULT_CHAT_FRAME:AddMessage(msg3, 0.0, 1.0, 0.0);
            --DEFAULT_CHAT_FRAME:AddMessage(msg4, 0.0, 1.0, 0.0);
            --DEFAULT_CHAT_FRAME:AddMessage(msg5, 0.0, 1.0, 0.0);
            --DEFAULT_CHAT_FRAME:AddMessage(msg6, 0.0, 1.0, 0.0);  
            while margin  > 0 do
                --DEFAULT_CHAT_FRAME:AddMessage("margin > 0", 0.0, 1.0, 0.0);
                margin = margin - 1;      
                if cheapestLootTrashSlot and cheapestTrashBag then
                    --DEFAULT_CHAT_FRAME:AddMessage("cheapest loot && cheapest trash", 0.0, 1.0, 0.0);
                    if cheapestTrashValue <= cheapestLootTrashValue then
                        cheapestTrashBag, cheapestTrashSlot, cheapestTrashValue = inventory:cheapestTrash();
                        --DEFAULT_CHAT_FRAME:AddMessage("bags < loot", 0.0, 1.0, 0.0);
                        msg = string.format("myLooter: Deleted %s", GetContainerItemLink(cheapestTrashBag,cheapestTrashSlot));          
                        ClearCursor();
                        PickupContainerItem(cheapestTrashBag, cheapestTrashSlot);
                        DeleteCursorItem();
                        DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0);
                        --DEFAULT_CHAT_FRAME:AddMessage("yielding", 0.0, 1.0, 0.0);
                        coroutine.yield();
                        --DEFAULT_CHAT_FRAME:AddMessage("back", 0.0, 1.0, 0.0);
                        cheapestTrashBag, cheapestTrashSlot, cheapestTrashValue = inventory:cheapestTrash();
                        margin = margin - 1;              
                    else
                        --DEFAULT_CHAT_FRAME:AddMessage("bags > loot", 0.0, 1.0, 0.0);              
                        if freeSlots > 0 then
                            --lootLink = GetLootSlotLink(cheapestLootTrashSlot);
                            --msg = string.format("myLooter: cheapest trash is in lootbox %s" lootLink);
                            --DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0);
                            --DEFAULT_CHAT_FRAME:AddMessage("freeslots > 0, attempting to loot slot", 0.0, 1.0, 0.0);
                            ClearCursor();
                            LootSlot(cheapestLootTrashSlot);
                            --DEFAULT_CHAT_FRAME:AddMessage("yielding", 0.0, 1.0, 0.0);
                            coroutine.yield();
                            --DEFAULT_CHAT_FRAME:AddMessage("back", 0.0, 1.0, 0.0);
                            cheapestTrashBag, cheapestTrashSlot, cheapestTrashValue = inventory:cheapestTrash();
                            if cheapestTrashBag then
                                msg = string.format("myLooter: Deleted %s", GetContainerItemLink(cheapestTrashBag,cheapestTrashSlot));
                                PickupContainerItem(cheapestTrashBag, cheapestTrashSlot);
                                DeleteCursorItem();
                                DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0);
                                --DEFAULT_CHAT_FRAME:AddMessage("yielding", 0.0, 1.0, 0.0);
                                coroutine.yield();
                                --DEFAULT_CHAT_FRAME:AddMessage("back", 0.0, 1.0, 0.0);
                                cheapestTrashBag, cheapestTrashSlot, cheapestTrashValue = inventory:cheapestTrash();
                                cheapestLootTrashSlot, cheapestLootTrashValue = lootbox:cheapestLootTrash();  
                                margin = margin - 1;
                            else
                                DEFAULT_CHAT_FRAME:AddMessage("myLooter: LootSlot() didn't finish in time for cheapestTrash()", 0.0, 1.0, 0.0);
                            end
                        else
                            DEFAULT_CHAT_FRAME:AddMessage("myLooter: Need at least one free slot in bags to work", 0.0, 1.0, 0.0);
                        end
                    end       
                elseif cheapestLootTrashSlot and (not cheapestTrashBag) then
                    --case = "loot";
                    --DEFAULT_CHAT_FRAME:AddMessage("loot", 0.0, 1.0, 0.0);        
                    if freeSlots > 0 then
                        LootSlot(cheapestLootTrashSlot);
                        ClearCursor();
                        cheapestTrashBag, cheapestTrashSlot, cheapestTrashValue = inventory:cheapestTrash();
                        if cheapestTrashBag then
                            msg = string.format("myLooter: Deleting %s", GetContainerItemLink(cheapestTrashBag,cheapestTrashSlot));
                            PickupContainerItem(cheapestTrashBag, cheapestTrashSlot);
                            DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0);
                            DeleteCursorItem();
                            coroutine.yield();
                            cheapestTrashBag, cheapestTrashSlot, cheapestTrashValue = inventory:cheapestTrash();
                            margin = margin - 1;
                        else
                            DEFAULT_CHAT_FRAME:AddMessage("myLooter: LootSlot() didn't finish in time for cheapestTrash()", 0.0, 1.0, 0.0);
                        end
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("myLooter: Need at least one free slot in bags to work", 0.0, 1.0, 0.0);
                    end  
                elseif (not cheapestLootTrashSlot) and cheapestTrashBag then
                    --case = "bags";
                    --DEFAULT_CHAT_FRAME:AddMessage("bags", 0.0, 1.0, 0.0);        
                    ClearCursor();
                    msg = string.format("myLooter: Deleting %s", GetContainerItemLink(cheapestTrashBag,cheapestTrashSlot));
                    PickupContainerItem(cheapestTrashBag, cheapestTrashSlot);
                    DeleteCursorItem();
                    DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0);
                    coroutine.yield();
                    cheapestTrashBag, cheapestTrashSlot, cheapestTrashValue = inventory:cheapestTrash();
                    margin = margin - 1;        
                elseif (not cheapestLootTrashSlot) and (not cheapestTrashBag) then
                    --case = "none";
                    --DEFAULT_CHAT_FRAME:AddMessage("none", 0.0, 1.0, 0.0);        
                    margin = -9999; -- break out of the while loop
                    DEFAULT_CHAT_FRAME:AddMessage("myLooter: Out of space and no more trash exists to be deleted.", 0.0, 1.0, 0.0);      
                else
                    message("Severe Error in myLooter");
                end           
            end 
        end
        --DEFAULT_CHAT_FRAME:AddMessage("done", 0.0, 1.0, 0.0);
        coroutine.yield();
    end
end
  
function myLooter.myLootbox:new()
    local self = {};
    setmetatable(self, myLooter.myLootbox);
    return self;
end
  
function myLooter.myLootbox:lootSlots()
    --DEFAULT_CHAT_FRAME:AddMessage("in lootSlots", 0.0, 1.0, 0.0);
    local slots = 0;
    local lootslot = 1;
    for lootslot=1,GetNumLootItems() do
        --DEFAULT_CHAT_FRAME:AddMessage("in lootSlots while loop", 0.0, 1.0, 0.0);
        local item = GetLootSlotLink(lootslot);
        local itemID, _, _, _, lootItemName, _, _, _, _ = myLooter.BreakLink(item);
        local itemInfo = Informant.GetItem(itemID);
        local maxStack = itemInfo.stack;
        local _, _, lootQuantity, _ = GetLootSlotInfo(lootslot);
        for bag = 0, 4, 1 do
            size = GetContainerNumSlots(bag)
            if (size) then
                for slot = size, 1, -1 do
                    local link = GetContainerItemLink(bag, slot)
                    if (link) then                    
                        local bagItemID, _, _, _, bagItemName, _, _, _, _ = myLooter.BreakLink(link)
                        if (lootItemName == bagItemName) then
                            local _, bagItemCount, _, _, _ = GetContainerItemInfo(bag, slot);
                            local bagItemRoom = maxStack - bagItemCount;
                            local msg = string.format("bagItemRoom = %d - %d", maxStack, bagItemCount);
                            lootQuantity = lootQuantity - bagItemRoom;
                            --DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0);
                        end
                    end
                end
            end
        end
        if lootQuantity > 0 then
            slots = slots + 1;
        end
    end
    msg = string.format("lootSlots returning %d slots will take up room in bags", slots);
    --DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0);
    return slots;
end
  
  function myLooter.myLootbox:cheapestLootTrash()
    local cheapestValue = 999;
    local cheapestItem = nil;
    local cheapestItemSlot = nil;
    for slot=1,GetNumLootItems() do
      local item = GetLootSlotLink(slot);
      if item then
        local _, _, itemCount, _ = GetLootSlotInfo(slot);
        if myLooter.isTrash(item) then
          local value = myLooter.returnValue(item);
          if value then
            value = value*itemCount;
            if value < cheapestValue then
              cheapestValue = value;
              cheapestItemSlot = slot;
            end
          end
        end
      end      
    end
    return cheapestItemSlot, cheapestValue
  end
  
function myLooter.myInventory:new()
    local self = {};
    setmetatable(self, myLooter.myInventory);
    self.items = {};
    return self;
end
  
function myLooter.myInventory:cheapestTrash()
    local cheapestValue = 9999;
    local cheapestItem = nil;
    local cheapestItemBag = nil;
    local cheapestItemSlot = nil;
    local bagSlots = {};
    for bagIndex=0,NUM_BAG_SLOTS do
        if GetBagName(bagIndex) then
            table.insert(bagSlots, bagIndex);
        end
    end
    for index,bagID in ipairs(bagSlots) do  
        local bagsize = GetContainerNumSlots(bagID);
        for slot=1,bagsize do
            local item = GetContainerItemLink(bagID,slot);
            if item then
                local _, itemCount, _, _, _ = GetContainerItemInfo(bagID,slot);
                if myLooter.isTrash(item) then
                    local value = myLooter.returnValue(item);
                    if value then
                        value = value*itemCount;
                        if value < cheapestValue then
                            cheapestValue = value;
                            cheapestItemBag = bagID;
                            cheapestItemSlot = slot;
                        end
                    end
                end
            end
        end
    end
    return cheapestItemBag, cheapestItemSlot, cheapestValue;
end
  
function myLooter.myInventory:load()
    local bagSlots = {};
    for bagIndex=0,NUM_BAG_SLOTS do
        if GetBagName(bagIndex) then
            table.insert(bagSlots, bagIndex);
        end
    end
    for index,bagID in ipairs(bagSlots) do 
        local bagsize = GetContainerNumSlots(bagID);
        for slot=0,bagsize do
            item = GetContainerItemLink(bagID,slot);
            if item then
                table.insert(self.items, item);
            end
        end
    end
  end
  
function myLooter.myInventory:totalSlots()
    local totalSlots = 0;
    local bagSlots = {};
    for bagIndex=0,NUM_BAG_SLOTS do
        if GetBagName(bagIndex) then
            table.insert(bagSlots, bagIndex);
        end
    end
    for index,bagID in ipairs(bagSlots) do 
        local bagsize = GetContainerNumSlots(bagID);
        totalSlots = totalSlots + bagsize
    end
    return totalSlots;
  end
  
function myLooter.myInventory:usedSlots()
    local usedSlots = 0;
    local bagSlots = {};
    for bagIndex=0,NUM_BAG_SLOTS do
        if GetBagName(bagIndex) then
            table.insert(bagSlots, bagIndex);
        end
    end
    for index,bagID in ipairs(bagSlots) do  
        local bagsize = GetContainerNumSlots(bagID);
        for slot=0,bagsize do
            item = GetContainerItemLink(bagID,slot);
            if item then
                usedSlots = usedSlots + 1;
            end
        end
    end
    return usedSlots;
end
  
function myLooter.myInventory:freeSlots()
    return self.totalSlots() - self.usedSlots();
end
  
function myLooter.onEvent(self, event, ...)
    msg = string.format("event = %s", event);
    --DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0);
    myLooter.lastevent = event;
    coroutine.resume(myLooter.coMain);
end



myLooter.lastevent = "";
myLooter.coMain = coroutine.create(myLooter.main);
myLooter.myLooter_frame1 = CreateFrame("Frame", "MyAddOnFrame", nil);
myLooter.myLooter_frame1:RegisterEvent("LOOT_OPENED");
myLooter.myLooter_frame1:RegisterEvent("BAG_UPDATE");
myLooter.myLooter_frame1:SetScript("OnEvent", myLooter.onEvent);

