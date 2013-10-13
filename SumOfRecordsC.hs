module SumOfRecordsC (printAll) where

import Data.List
import Data.Char

structPostfix = "_str"
unionPostfix = "_uni"
typePostfix = "_t"
polymorphicTypePostfix = "_T"
polymorphicEnumPostfix = "_E"
constructorPostfix = "_C"
deconstructorPostfix = "_D"
unionMemberPostfix = "_U"
defaultIndent = "        "
enumInStruct = "e"
unionInStruct = "u"


data PolymorphicType a = PolymorphicType {
      contents :: [ExtendedPrimitiveType a],
      name :: String
    }

type ExtendedPrimitiveType a = (String, a)

showEpt :: Show a => ExtendedPrimitiveType a -> String    
showEpt (tName, tType) = (show tType) ++ " " ++ tName

printStruct msg = do
  printStructCheckEmtpy (contents msg)
  where
    printStructCheckEmtpy [] =
      putStr $ "typedef void * " ++ (name msg) ++ polymorphicTypePostfix ++ ";\n"
    printStructCheckEmtpy _ = do
      putStr $ "struct " ++ (name msg) ++ structPostfix ++ " {\n"
      mapM_ (\ept -> putStr $ defaultIndent ++ (showEpt ept) ++ ";\n")
        (contents msg)
      putStr "};\n"
      putStr $ "typedef struct " ++ (name msg) ++ structPostfix ++ " "
        ++ (name msg) ++ polymorphicTypePostfix ++ ";\n"

printUnion mainStruct msgList = do
  putStr $ "union " ++ mainStruct ++ unionPostfix ++ " {\n"
  mapM_ (\msg -> putStr $ defaultIndent ++ (name msg)
                 ++ polymorphicTypePostfix ++ " " ++ (name msg)
                        ++ unionMemberPostfix ++ ";\n") msgList
  putStr $ "};"
  putStr "\n"

printMainStruct mainStruct enumName = do
  putStr $ "struct " ++ mainStruct ++ structPostfix ++ " {\n"
  putStr $ defaultIndent ++ "enum " ++ enumName ++ " " ++ enumInStruct ++ ";\n"
  putStr $ defaultIndent ++ "union " ++ mainStruct ++ unionPostfix ++ " "
         ++ unionInStruct ++ ";\n"
  putStr $ "};\n"
  putStr $ "typedef struct " ++ mainStruct ++ structPostfix ++ " "
         ++ mainStruct ++ typePostfix ++ ";\n"

printConstructor mainStruct msg = do
  putStr $ "__attribute__((unused)) static " ++ mainStruct ++ typePostfix
         ++ "\n"
  putStr $ (name msg) ++ constructorPostfix ++ "("
  putStr $ intercalate ", " (map (\ept -> showEpt ept) (contents msg))
  putStr $ ") {\n"
  putStr defaultIndent
  putStr $ mainStruct ++ typePostfix ++ " " ++ mainStruct ++ ";\n"
  putStr defaultIndent
  putStr $ mainStruct ++ "." ++ enumInStruct ++ " = "
    ++ (name msg) ++ polymorphicEnumPostfix ++ ";\n"
  printConstructorCheckEmpty (contents msg)
  putStr defaultIndent
  putStr $ "return " ++ mainStruct ++ ";\n}\n"
  where
    printConstructorCheckEmpty [] = do
      putStr $ defaultIndent ++ mainStruct ++ "." ++ unionInStruct ++ "."
        ++ (name msg) ++ unionMemberPostfix
        ++ " = (" ++ (name msg) ++ polymorphicTypePostfix ++ " *)"
        ++ "NULL;\n"
    printConstructorCheckEmpty _ = do
      mapM_ (\(tName, tType) -> putStr $
                                defaultIndent ++ mainStruct ++ "." ++ unionInStruct ++ "."
                                ++ (name msg) ++ unionMemberPostfix ++ "."
                                ++ tName ++ " = " ++ tName ++ ";\n")
        (contents msg)

printDeconstructorSafe mainStruct msg = do
  putStr $ "__attribute__((unused)) static " ++ (name msg) ++ polymorphicTypePostfix
         ++ "\n"
  putStr $ (name msg) ++ deconstructorPostfix ++ "("
  putStr $ mainStruct ++ typePostfix ++ " " ++ mainStruct
  putStr $ ") {\n"
  putStr defaultIndent
  putStr $ "assert(" ++ mainStruct ++ "." ++ enumInStruct ++ " == "
    ++ (name msg) ++ polymorphicEnumPostfix ++ ");\n"
  putStr defaultIndent
  putStr $ "return " ++ mainStruct ++ "." ++ unionInStruct ++ "."
    ++ (name msg) ++ unionMemberPostfix ++ ";\n}\n"
    
printDeconstructorUnsafe mainStruct msg = do
  putStr $ "#define " ++ (name msg) ++ deconstructorPostfix ++ "("
    ++ mainStruct ++ ") (" ++ mainStruct ++ ").u." ++ (name msg)
    ++ unionMemberPostfix ++ "\n"
  
               
process mainStruct enumName msgList dynamicTypeCheck = do
  putStr $ "enum " ++ enumName ++ " {\n" ++ defaultIndent
  putStr $ intercalate (",\n" ++ defaultIndent)
    (map (\msg -> (name msg) ++ polymorphicEnumPostfix) msgList)
  putStr "\n};\n"
  mapM_ printStruct msgList
  printUnion mainStruct msgList
  printMainStruct mainStruct enumName
  mapM_ (printConstructor mainStruct) msgList
  if dynamicTypeCheck then
    mapM_ (printDeconstructorSafe mainStruct) msgList
    else
    mapM_ (printDeconstructorUnsafe mainStruct) msgList
                 
printAll wordsForType myTypeStrings dynamicTypeCheck = do
  putStr "#include <assert.h>\n"
  putStr $ "#define TYPE(x) ((x)." ++ enumInStruct ++ ")\n"
  process mainStruct enumName myTypes dynamicTypeCheck
  where
    myTypes = map createPolymorphicType myTypeStrings
    createPolymorphicType (consName, productTerms) =
      PolymorphicType {name = consName, contents = productTerms}
    little s = map toLower s
    capitalize [] = []
    capitalize (x : rest) = (toUpper x) : (little rest)
    (mainStruct, enumName) = (intercalate "_" (map little wordsForType),
                              concat (map capitalize wordsForType))
