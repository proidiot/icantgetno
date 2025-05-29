#!/usr/bin/awk -f

# CNF: (a \/ b \/ c) /\ (-a \/ b \/ d) /\ (b \/ -c \/ d)
#
# same thing converted to...
#
# DNF: (a /\ -a /\ b) \/ (a /\ -a /\ -c) \/ (a /\ -a /\ d)
#      \/ (a /\ b /\ b) \/ (a /\ b /\ -c) \/ (a /\ b /\ d)
#      \/ (a /\ d /\ b) \/ (a /\ d /\ -c) \/ (a /\ d /\ d)
#      \/ (b /\ -a /\ b) \/ (b /\ -a /\ -c) \/ (b /\ -a /\ d)
#      \/ (b /\ b /\ b) \/ (b /\ b /\ -c) \/ (b /\ b /\ d)
#      \/ (b /\ d /\ b) \/ (b /\ d /\ -c) \/ (b /\ d /\ d)
#      \/ (c /\ -a /\ b) \/ (c /\ -a /\ -c) \/ (c /\ -a /\ d)
#      \/ (c /\ b /\ b) \/ (c /\ b /\ -c) \/ (c /\ b /\ d)
#      \/ (c /\ d /\ b) \/ (c /\ d /\ -c) \/ (c /\ d /\ d)
#
# ...and that is why you don't convert from CNF to DNF.
#
# But if you ALREADY have DNF...

/^p dnf [1-9][0-9]* [1-9][0-9]*$/ {
	vars = 0 + $3;
	clauses = 0 + $4;

	for (var = 1; var <= vars; var++) {
		vals[var] = "unknown";
	}
	contradiction = 0;
#	print "DEBUG: header", vars, clauses;
}

/^ *-?[1-9]/ {
#	print "DEBUG: clause", $0;
	contradiction = 0;
	for (i = 1; i <= NF; i++) {
#		print "DEBUG: word", $i;
		if ($i == "0") {
			# reset
			if (contradiction != 1) {
				print "s SATISFIABLE";
				printf("v");
				for (var = 1; var <= NF; var++) {
					if (vals[var] != "true") {
						printf(" -%d", var);
					} else {
						printf(" %d", var);
					}
				}
				print " 0";
				exit 0;
			}

			for (var = 1; var <= vars; var++) {
				vals[var] = "unknown";
			}
		} else if (contradiction != 1 && $i ~ /^-?[1-9][0-9]*$/) {
#			print "DEBUG: raw var", $i;
			svar = 0 + $i;
			if (svar < 0) {
				var = -svar;
				val = "false";
			} else {
				var = svar;
				val = "true";
			}
#			print "DEBUG: var", var, "val", val;

			if (vals[var] == "unknown") {
				vals[var] = val;
			} else if (vals[var] != val) {
				contradiction = 1;
#				print "DEBUG: contradiction at position", i, "value", vals[var];
		  }
		}
	}
}

END {
	if (contradiction == 1) {
		print "s UNSATISFIABLE";
		exit 1;
	}
}
