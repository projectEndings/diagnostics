# Diagnostics
Programmed diagnostics enable projects to enforce coherence and consistency, manage the workflow effectively, and measure their progress towards completeness. 

This project will provide an [Oxygen](https://www.oxygenxml.com) project which you can open, then press a button, select a folder, and run a diagnostic process against your [TEI](https://www.tei-c.org) XML project files, generating an HTML page showing statistics, errors and warnings based on an analysis of your XML documents. The process is an ant task that can also be run outside Oxygen, supplying a single parameter, which is the path to the folder containing your TEI project.

The diagnostic process checks that:

 - All pointer attributes within a document point to @xml:ids that exist in the document.
 - All pointers to other documents in the collection, or to @xml:id attributes in those documents, are correct.
 - All values for the @xml:lang attribute are correct.

It will dereference private URI schemes which are correctly declared in TEI <prefixDef> elements. Incorrect values are listed by document.

It will also generate a list of all the elements and attributes used in the project, along with usage counts.

See the [Instructions](instructions.html) for full details.

