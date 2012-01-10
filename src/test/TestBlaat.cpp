#include "TestBlaat.h"

BlaatTester::BlaatTester()
{
}

BlaatTester::~BlaatTester()
{
}

void BlaatTester::adderTest()
{
	int result (adder(1, 1));
	CPPUNIT_ASSERT_EQUAL(2, result);
}

