#include <string>
#include <ctype.h>
// namespaces
using namespace std;

string StringToLower(string strToConvert)

{//change each element of the string to lower case

   for(unsigned int i=0;i<strToConvert.length();i++)

   {
      strToConvert[i] = tolower(strToConvert[i]);
   }
   return strToConvert;//return the converted string
} 
