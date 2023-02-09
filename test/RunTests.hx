package test;

import utest.Runner;
import utest.ui.Report;

class RunTests {
	public static function main() {
		 var runner = new Runner();
		 runner.addCase(new FloorGenTests());
		 Report.create(runner);
		 runner.run();
	  }
}