#include "UnitTests.h"
#include "CppUnitWrapper.h"
#include <iostream>


int main() 
{
	CppUnitWrapper theRunner;
	theRunner.setOutputType (CppUnitWrapper::kXmlOutput);

	bool wasSucessful = theRunner.run ();

	// Return error code 1 if the one of test failed.
	return (wasSucessful ? 0 : 1);
}
