''
'' Provides a generic (datatype Any Ptr) single linked list.
''
'' @author Tapio Vierros

''	Internal list node.
	Type SingleLinkedListNode
		nextNode 	As SingleLinkedListNode Ptr 	= 0
		nodeData 	As Any Ptr						= 0
	End Type

''	Single linked list.
	Type SingleLinkedList
		firstNode 		As SingleLinkedListNode Ptr = 0
		iteratorNode 	As SingleLinkedListNode Ptr = 0
		
		itemCount		As UInteger
		
		Declare Destructor()
		Declare Sub add				(_item As Any Ptr)
		Declare Function remove		(_item As Any Ptr) As Any Ptr
		Declare Function contains	(_item As Any Ptr) As Integer
		
		Declare Function initIterator	() As Any Ptr
		Declare Function getNext		() As Any Ptr
	End Type

''	Destroys the list and its nodes, but not the contents of the data pointers.
	Destructor SingleLinkedList()
		Var iterNode = this.firstNode
		While iterNode <> 0
			Var nextNode = iterNode->nextNode
			Delete iterNode
			iterNode = nextNode
		Wend
	End Destructor


''	Adds an item to the front of the list.
''	@param _item As Any Ptr - a pointer to the data-to-be-stored.
	Sub SingleLinkedList.add(_item As Any Ptr)
		Var newNode = New SingleLinkedListNode
		newNode->nodeData = _item
		newNode->nextNode = this.firstNode
		this.firstNode = newNode
		this.itemCount += 1
	End Sub


''	Removes an item from the list (but does not delete the data).
''	@param _item As Any Ptr - a pointer to the data-to-be-removed.
''	@returns Any Ptr - pointer to the data of the deleted node.
	Function SingleLinkedList.remove(_item As Any Ptr) As Any Ptr
		Var iterNode = this.firstNode
		Dim prevNode As SingleLinkedListNode Ptr = 0
		While iterNode <> 0
			If iterNode->nodeData = _item Then
				If prevNode <> 0 Then
					prevNode->nextNode = iterNode->nextNode
				Else
					this.firstNode = iterNode->nextNode
				EndIf
				If this.iteratorNode = iterNode Then this.iteratorNode = iterNode->nextNode
				Dim As Any Ptr ret = iterNode->nodeData
				Delete iterNode
				this.itemCount -= 1
				Return ret
			EndIf
			prevNode = iterNode
			iterNode = iterNode->nextNode
		Wend
	End Function


''	Returns non-zero if the list contains the given item.
''	@param _item As Any Ptr a pointer to the data-to-be-searched-for.
	Function SingleLinkedList.contains(_item As Any Ptr) As Integer
		Var iterNode = this.firstNode
		While iterNode <> 0
			If iterNode->nodeData = _item Then Return (Not 0)
			iterNode = iterNode->nextNode
		Wend
		Return 0
	End Function


''	Initializes iteration cycle and returns first node.
	Function SingleLinkedList.initIterator() As Any Ptr
		this.iteratorNode = this.firstNode
		Return this.getNext()
	End Function


''	Gets the next node in list in the iteration started by initIterator.
	Function SingleLinkedList.getNext() As Any Ptr
		If this.iteratorNode = 0 Then Return 0
		Function = this.iteratorNode->nodeData
		If this.iteratorNode <> 0 Then this.iteratorNode = this.iteratorNode->nextNode
	End Function
	



	#Macro DeclareSingleLinkedListType(LINKED_LIST_DATA_TYPE)

		Dim Shared LINKED_LIST_DATA_TYPE##LINKED_LIST_DATA_TYPE_DEFAULT As _
			LINKED_LIST_DATA_TYPE

	''	Internal list node.
		Type LINKED_LIST_DATA_TYPE##SingleLinkedListNode
			nextNode 	As LINKED_LIST_DATA_TYPE##SingleLinkedListNode Ptr = 0
			nodeData 	As LINKED_LIST_DATA_TYPE
		End Type

	''	Single linked list.
		Type LINKED_LIST_DATA_TYPE##SingleLinkedList
			firstNode 		As LINKED_LIST_DATA_TYPE##SingleLinkedListNode Ptr = 0
			iteratorNode 	As LINKED_LIST_DATA_TYPE##SingleLinkedListNode Ptr = 0
			
			itemCount		As UInteger
			
			Declare Destructor()
			Declare Sub add				(_item As LINKED_LIST_DATA_TYPE)
			Declare Sub remove			(_item As LINKED_LIST_DATA_TYPE)
			Declare Function contains	(_item As LINKED_LIST_DATA_TYPE) As Integer
			
			Declare Function initIterator	() As LINKED_LIST_DATA_TYPE
			Declare Function getNext		() As LINKED_LIST_DATA_TYPE
		End Type

	''	Destroys the list and its nodes, but not the contents of the data pointers.
		Destructor LINKED_LIST_DATA_TYPE##SingleLinkedList()
			Var iterNode = this.firstNode
			While iterNode <> 0
				Var nextNode = iterNode->nextNode
				Delete iterNode
				iterNode = nextNode
			Wend
		End Destructor


	''	Adds an item to the front of the list.
	''	@param _item As LINKED_LIST_DATA_TYPE - a pointer to the data-to-be-stored.
		Sub LINKED_LIST_DATA_TYPE##SingleLinkedList.add(_item As LINKED_LIST_DATA_TYPE)
			Var newNode = New LINKED_LIST_DATA_TYPE##SingleLinkedListNode
			newNode->nodeData = _item
			newNode->nextNode = this.firstNode
			this.firstNode = newNode
			this.itemCount += 1
		End Sub


	''	Removes an item from the list.
	''	@param _item As LINKED_LIST_DATA_TYPE - a pointer to the data-to-be-removed.
		Sub LINKED_LIST_DATA_TYPE##SingleLinkedList.remove(_item As LINKED_LIST_DATA_TYPE)
			Var iterNode = this.firstNode
			Dim prevNode As LINKED_LIST_DATA_TYPE##SingleLinkedListNode Ptr = 0
			While iterNode <> 0
				If iterNode->nodeData = _item Then
					If prevNode <> 0 Then
						prevNode->nextNode = iterNode->nextNode
					Else
						this.firstNode = iterNode->nextNode
					EndIf
					If this.iteratorNode = iterNode Then this.iteratorNode = iterNode->nextNode
					Delete iterNode
					this.itemCount -= 1
					Return
				EndIf
				prevNode = iterNode
				iterNode = iterNode->nextNode
			Wend
		End Sub


	''	Returns non-zero if the list contains the given item.
	''	@param _item As LINKED_LIST_DATA_TYPE a pointer to the data-to-be-searched-for.
		Function LINKED_LIST_DATA_TYPE##SingleLinkedList.contains(_item As LINKED_LIST_DATA_TYPE) As Integer
			Var iterNode = this.firstNode
			While iterNode <> 0
				If iterNode->nodeData = _item Then Return (Not 0)
				iterNode = iterNode->nextNode
			Wend
			Return 0
		End Function


	''	Initializes iteration cycle and returns first node.
		Function LINKED_LIST_DATA_TYPE##SingleLinkedList.initIterator() As LINKED_LIST_DATA_TYPE
			this.iteratorNode = this.firstNode
			Return this.getNext()
		End Function


	''	Gets the next node in list in the iteration started by initIterator.
		Function LINKED_LIST_DATA_TYPE##SingleLinkedList.getNext() As LINKED_LIST_DATA_TYPE
			If this.iteratorNode = 0 Then Return LINKED_LIST_DATA_TYPE##LINKED_LIST_DATA_TYPE_DEFAULT
			Var ret = this.iteratorNode->nodeData
			If this.iteratorNode <> 0 Then this.iteratorNode = this.iteratorNode->nextNode
			Return ret
		End Function
		
	#EndMacro
