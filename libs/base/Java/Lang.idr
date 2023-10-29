module Java.Lang

import System.FFI

public export
interface Inherits child parent where
    constructor MkInherits

    export %inline
    subtyping : child -> parent
    subtyping = believe_me

public export
Inherits a a where

namespace Object
    public export
    Object : Type
    Object = Struct "java/lang/Object" []

    %foreign "jvm:.toString(java/lang/Object java/lang/String),java/lang/Object"
    prim_toString : Object -> PrimIO String

    export %inline
    toString : (HasIO io, Inherits a Object) => a -> io String
    toString obj = primIO $ prim_toString (subtyping obj)

public export
Inherits a Object where

namespace Class
  public export
  Class : Type -> Type
  Class ty = Struct "java/lang/Class" [("<>", ty)]

%extern prim__jvmClassLiteral : (ty: Type) -> Class ty

public export %inline
classLiteral : {ty: Type} -> Class ty
classLiteral {ty} = prim__jvmClassLiteral ty

public export
data Array : (elemTy: Type) -> Type where

%extern prim__jvmNewArray : (ty: Type) -> Int -> PrimIO (Array ty)

%extern prim__jvmSetArray : (a: Type) -> Int -> a -> Array a -> PrimIO ()

%extern prim__jvmGetArray : (a: Type) -> Int -> Array a -> PrimIO a

%extern prim__jvmArrayLength : (a: Type) -> Array a -> Int

isPrimitive : Type -> Bool
isPrimitive Bool = True
isPrimitive Char = True
isPrimitive Int8 = True
isPrimitive Int16 = True
isPrimitive Int32 = True
isPrimitive Int = True
isPrimitive Int64 = True
isPrimitive Bits8 = True
isPrimitive Bits16 = True
isPrimitive Bits32 = True
isPrimitive Bits64 = True
isPrimitive Double = True
isPrimitive _ = False

public export
%foreign jvm' "java/util/Objects" "isNull" "java/lang/Object" "boolean"
isNull : Object -> Bool

namespace Array
    %inline
    public export
    new : HasIO io => {elem: Type} -> Int -> io (Array elem)
    new {elem} size = primIO $ prim__jvmNewArray elem size

    %inline
    public export
    set : HasIO io => {elem: Type} -> Array elem -> Int -> elem -> io Bool
    set {elem} array index value = do
        let len = prim__jvmArrayLength elem array
        if index >= 0 && index < len
            then do
                    primIO $ prim__jvmSetArray elem index value array
                    pure True
            else pure False

    %inline
    public export
    get : HasIO io => {elem: Type} -> Array elem -> Int -> io (Maybe elem)
    get {elem} array index = do
     let len = prim__jvmArrayLength elem array
     if index >= 0 && index < len
        then do
            value <- primIO $ prim__jvmGetArray elem index array
            if isPrimitive elem
                then pure (Just value)
                else
                    if isNull (believe_me value)
                        then pure Nothing
                        else pure (Just value)
        else pure Nothing
