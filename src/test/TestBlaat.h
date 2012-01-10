#ifndef __BLAATTESTER_H
#define __BLAATTESTER_H

#include "cppunit/extensions/HelperMacros.h"
#include "../Blaat.h"

class BlaatTester : public CPPUNIT_NS::TestFixture {
public:
	BlaatTester();
	virtual ~BlaatTester();

public:
	// Declare test suite and cases
	CPPUNIT_TEST_SUITE(BlaatTester);
	CPPUNIT_TEST(adderTest);
	CPPUNIT_TEST_SUITE_END();

private:
	void adderTest();
};

#endif  // __BLAATTESTER_H
