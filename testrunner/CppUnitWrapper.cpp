#include "CppUnitWrapper.h"
#include <cppunit/extensions/TestFactoryRegistry.h>
#include <cppunit/CompilerOutputter.h>
#include <cppunit/XmlOutputter.h>
#include <cppunit/XmlOutputterHook.h>
#include <cppunit/tools/XmlElement.h>
#include <cppunit/tools/XmlDocument.h>

#include <fstream>
#include <string>
#include <ctime>


class MyXmlOutputterHook : public CPPUNIT_NS::XmlOutputterHook {
public:
	MyXmlOutputterHook(std::string inProjectName) : 
        mProjectName (inProjectName)
	{
	}

	virtual ~MyXmlOutputterHook() {
	}

	virtual void beginDocument (CPPUNIT_NS::XmlDocument* inDocument) {
		if (!inDocument) {
			return;
		}

		CPPUNIT_NS::XmlElement* theElement = new CPPUNIT_NS::XmlElement("TestSuiteInfo", "");
		theElement->addElement (new CPPUNIT_NS::XmlElement ("Project", mProjectName));

		//FTime theNow;
		//theElement->addElement (new CPPUNIT_NS::XmlElement ("Date",    theNow.AsUTCString (true)));
		char *timeString;
		const time_t rawtime = time (0);
		timeString = ctime (&rawtime);
		theElement->addElement (new CPPUNIT_NS::XmlElement ("Date", timeString));

		inDocument->rootElement ().addElement (theElement);
	}

private:
	std::string mProjectName;

};


CppUnitWrapper::CppUnitWrapper () : CPPUNIT_NS::TextUi::TestRunner (), theOutputterHook (0), theStream (0)
{
	// Get the top level suite from the registry
	CPPUNIT_NS::Test* suite = CPPUNIT_NS::TestFactoryRegistry::getRegistry().makeTest();
	// Adds the test to the list of test to run
	addTest (suite);
}

CppUnitWrapper::~CppUnitWrapper ()
{
	if (theStream)
	{
		if (theStream ->is_open ())
		{
			// Close the xml-format outputter stream
			theStream->close ();
			delete theStream;
			theStream = 0;
		}
	}

	if (theOutputterHook)
	{
		delete theOutputterHook;
		theOutputterHook = 0;
	}
}

void CppUnitWrapper::setOutputType (const enum eOUTPUTTYPES output) {

	// Gets cleaned by destructor of 'runner'
	CppUnit::Outputter* theOutputter = 0;

	// Change the default outputter to a
	if (output == kStdoutOutput) {

		//	compiler error format outputter
		theOutputter = new CppUnit::CompilerOutputter (&(this->result()), CPPUNIT_NS::stdCOut ());
	}
	else if (output == kXmlOutput)	{

		//	xml-format outputter
		theStream = new std::ofstream ("Test.xml");
		theOutputter = new CppUnit::XmlOutputter (&(this->result ()), *theStream);
		CPPUNIT_NS::XmlOutputter* xmlOutputter = dynamic_cast<CPPUNIT_NS::XmlOutputter*>(theOutputter);

		// Add stylesheet if possible
		//theOutputterHook = new CPPUNIT_NS::XmlOutputterHook ();
		theOutputterHook = new MyXmlOutputterHook ("UnitTestDemo");	
		if (xmlOutputter && theOutputterHook) {
			xmlOutputter->setStyleSheet ("testreport.xsl");
			xmlOutputter->addHook (theOutputterHook);
		}
	}
    else if (output == kXmlCIOutput) {

		//	xml-format outputter
		theStream = new std::ofstream ("CITest.xml");
		theOutputter = new CppUnit::XmlOutputter (&(this->result ()), *theStream);
		CPPUNIT_NS::XmlOutputter* xmlOutputter = dynamic_cast<CPPUNIT_NS::XmlOutputter*>(theOutputter);

		theOutputterHook = new CPPUNIT_NS::XmlOutputterHook ();
		if (xmlOutputter && theOutputterHook) {

			xmlOutputter->addHook (theOutputterHook);
		}
    }

	// set outputter
	if (theOutputter) {
		setOutputter (theOutputter);
	}
}
