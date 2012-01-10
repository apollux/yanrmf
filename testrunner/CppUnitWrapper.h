#ifndef	__CPPUNITWRAPPER_H
#define	__CPPUNITWRAPPER_H

#include "cppunit/ui/text/TestRunner.h"
#include "cppunit/XmlOutputterHook.h"
#include <fstream>


class CppUnitWrapper : public CPPUNIT_NS::TextUi::TestRunner
{
public:
	CppUnitWrapper (void);
	virtual ~CppUnitWrapper (void);

	enum eOUTPUTTYPES {
		kDefaultOutput,
		kStdoutOutput,
		kXmlOutput,             // XML used during manual builds
        kXmlCIOutput            // XML used by CI/build server
	};

	void setOutputType (const enum eOUTPUTTYPES output);

	void flush() {theStream->flush();}

private:
	CPPUNIT_NS::XmlOutputterHook* theOutputterHook;
	std::ofstream* theStream;

};

#endif	//	__CPPUNITWRAPPER_H
