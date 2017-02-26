##Machine Maker

The Cook–Levin theorem proves SAT is NP-complete, in part, by demonstrating a
polynonial-time reduction from any non-deterministic Turing machine to SAT. In
practice, this reduction is rarely constructed for any practical application.

Under normal circumstances, a Turing machine description and an initial
configuration are provided and the resulting SAT problem is satisfiable if the
machine represented by the SAT problem accepts its input.

This project explores a novel application of this reduction. Instead of
providing a machine description and initial configuration, it provides multiple
input/output pairs that specify how the machine should behave, i.e. what its
description should be to produce each computation.

The project was successful in that it can find Turing machines from input/output
pairs, but in practice, the search process is prohibitively slow for all but
trivial machines. For an example, refer to `spec/machine_maker/search_spec.rb`.
