sub init()
    m.top.selectedCategory = ""
    m.list = m.top.FindNode("categoryGrid")
    m.list.observeField("itemSelected", "OnCategorySelected")
    m.list.setFocus(true)
end sub

function OnCategorySelected()
    categoryIndex = m.list.itemSelected 'get the index to find the category
    category = m.list.content.getChild(categoryIndex).shortdescriptionline1    
    m.top.selectedCategory = LCase(category)
end function


