--
-- Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
-- Licensed under the MIT license. See LICENSE file in the project root for details.
--

---@meta

---@type fun(name: string, handler: fun(name: string))
MainMenuAPIAddGamemode = nil

---@class GUIComponent
---@field SetText fun(self: self, text: string)
---@field SetTextLocalizationKey fun(self: self, key: string, updateText: boolean?)
---@field UseDefaultText fun(self: self)

---@class MenuScreen
---@field CreateBack fun(self: self, oppacity: number)
---@field CreateBackground fun(self: self, textureName: string)
---@field CreateTitleText fun(self: self)
---@field SetLowerInputBlock fun(self: self, state: boolean)
---@field CreateCancelButton fun(self: self, handler: fun())
---@field AddReflection fun(self: self, name: string, component: GUIComponent)
---@field LoadDefenitions fun(self: self, path: string)
---@field ExitScreen fun(self: self)

---@class GUIComponentTextBox : GUIComponent

---@type fun(): MenuScreen
CreateMenuScreen = nil

---@class GUIComponentButton : GUIComponent
---@field AddActivationHandler fun(self: self, handler: fun())

---@type fun(screen: MenuScreen): GUIComponentButton
CreateGUIComponentButton = nil

---@type fun(screen: MenuScreen): GUIComponentTextBox
CreateGUIComponentTextBox = nil
