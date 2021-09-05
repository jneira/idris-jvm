module Compiler.Jvm.InferredType

import Data.Strings

public export
data InferredType = IBool | IByte | IChar | IShort | IInt | ILong | IFloat | IDouble | IRef String
                  | IArray InferredType | IVoid | IUnknown

export
Eq InferredType where
  IBool == IBool = True
  IByte == IByte = True
  IChar == IChar = True
  IShort == IShort = True
  IInt == IInt = True
  ILong == ILong = True
  IFloat == IFloat = True
  IDouble == IDouble = True
  (IRef ty1) == (IRef ty2) = ty1 == ty2
  (IArray elemTy1) == (IArray elemTy2) = elemTy1 == elemTy2
  IUnknown == IUnknown = True
  IVoid == IVoid = True
  _ == _ = False

export
Show InferredType where
    show IBool = "boolean"
    show IByte = "byte"
    show IChar = "char"
    show IShort = "short"
    show IInt = "int"
    show ILong = "long"
    show IFloat = "float"
    show IDouble = "double"
    show (IRef clsName) = clsName
    show (IArray elemTy) = "Array " ++ show elemTy
    show IUnknown = "unknown"
    show IVoid = "void"

%inline
public export
inferredObjectType : InferredType
inferredObjectType = IRef "java/lang/Object"

%inline
public export
bigIntegerClass : String
bigIntegerClass = "java/math/BigInteger"

%inline
public export
inferredBigIntegerType : InferredType
inferredBigIntegerType = IRef bigIntegerClass

%inline
public export
stringClass : String
stringClass = "java/lang/String"

%inline
public export
inferredStringType : InferredType
inferredStringType = IRef stringClass

%inline
public export
inferredLambdaType : InferredType
inferredLambdaType = IRef "java/util/function/Function"

%inline
public export
inferredForkJoinTaskType : InferredType
inferredForkJoinTaskType = IRef "java/util/concurrent/ForkJoinTask"

%inline
public export
arrayListClass : String
arrayListClass = "java/util/ArrayList"

%inline
public export
arrayListType : InferredType
arrayListType = IRef arrayListClass

%inline
public export
idrisSystemClass : String
idrisSystemClass = "io/github/mmhelloworld/idrisjvm/runtime/IdrisSystem"

%inline
public export
idrisListClass : String
idrisListClass = "io/github/mmhelloworld/idrisjvm/runtime/IdrisList"

%inline
public export
idrisListType : InferredType
idrisListType = IRef idrisListClass

%inline
public export
idrisNilClass : String
idrisNilClass = "io/github/mmhelloworld/idrisjvm/runtime/IdrisList$Nil"

%inline
public export
idrisNilType : InferredType
idrisNilType = IRef idrisNilClass

%inline
public export
idrisConsClass : String
idrisConsClass = "io/github/mmhelloworld/idrisjvm/runtime/IdrisList$Cons"

%inline
public export
idrisConsType : InferredType
idrisConsType = IRef idrisConsClass

export
isPrimitive : InferredType -> Bool
isPrimitive IBool = True
isPrimitive IByte = True
isPrimitive IChar = True
isPrimitive IShort = True
isPrimitive IInt = True
isPrimitive ILong = True
isPrimitive IFloat = True
isPrimitive IDouble = True
isPrimitive _ = False

%inline
public export
getRuntimeClass : String -> String
getRuntimeClass name = "io/github/mmhelloworld/idrisjvm/runtime/" ++ name

%inline
public export
intThunkClass : String
intThunkClass = getRuntimeClass "IntThunk"

%inline
public export
doubleThunkClass : String
doubleThunkClass = getRuntimeClass "DoubleThunk"

%inline
public export
thunkClass : String
thunkClass = getRuntimeClass "Thunk"

%inline
public export
intThunkType : InferredType
intThunkType = IRef intThunkClass

%inline
public export
doubleThunkType : InferredType
doubleThunkType = IRef doubleThunkClass

%inline
public export
thunkType : InferredType
thunkType = IRef thunkClass

%inline
public export
delayedClass : String
delayedClass = getRuntimeClass "Delayed"

%inline
public export
delayedType : InferredType
delayedType = IRef delayedClass

%inline
public export
idrisObjectClass : String
idrisObjectClass = getRuntimeClass "IdrisObject"

%inline
public export
arraysClass : String
arraysClass = getRuntimeClass "Arrays"

%inline
public export
refClass : String
refClass = getRuntimeClass "Ref"

%inline
public export
refType : InferredType
refType = IRef refClass

%inline
public export
idrisObjectType : InferredType
idrisObjectType = IRef idrisObjectClass

public export
isRefType : InferredType -> Bool
isRefType (IRef _) = True
isRefType _ = False

public export
Semigroup InferredType where
  IUnknown <+> ty2 = ty2
  ty1 <+> IUnknown = ty1
  ty1 <+> ty2 = if ty1 == ty2 then ty1 else inferredObjectType

%inline
public export
Monoid InferredType where
  neutral = IUnknown

export
stripInterfacePrefix : InferredType -> InferredType
stripInterfacePrefix (IRef className) =
    IRef $ if "i:" `isPrefixOf` className then substr 2 (length className) className else className
stripInterfacePrefix ty = ty

export
parse : String -> InferredType
parse "boolean" = IBool
parse "byte" = IByte
parse "char" = IChar
parse "short" = IShort
parse "int" = IInt
parse "long" = ILong
parse "float" = IFloat
parse "double" = IDouble
parse "String" = inferredStringType
parse "BigInteger" = inferredBigIntegerType
parse "void" = IVoid
parse className = IRef className

export
createExtPrimTypeSpec : InferredType -> String
createExtPrimTypeSpec IBool = "Bool"
createExtPrimTypeSpec IByte = "Byte"
createExtPrimTypeSpec IShort = "Short"
createExtPrimTypeSpec IInt = "Int"
createExtPrimTypeSpec IChar = "Char"
createExtPrimTypeSpec ILong = "long"
createExtPrimTypeSpec IFloat = "float"
createExtPrimTypeSpec IDouble = "Double"
createExtPrimTypeSpec (IArray ty) = "[" ++ createExtPrimTypeSpec ty
createExtPrimTypeSpec IVoid = "void"
createExtPrimTypeSpec IUnknown = createExtPrimTypeSpec inferredObjectType
createExtPrimTypeSpec (IRef ty) = ty