# HTCondor manylinux Python Wheel Building Routines

1. Choose which version of manylinux to build for. Versions currently available:
   * `manylinux2014` - Builds inside CentOS 7-based Docker container. (`x86_64` for HTCondor 23.0)
   * `manylinux_2_28` - Builds inside AlmaLinux 8-based Docker container. (`x86_64` and `ARM` for HTCondor 23.x+)
2. Once in the directory for the chosen manylinux version, if not yet built, build the Docker image:
   1. Update `latest_tag` to a unique version number (I usually use the latest version of HTCondor that I'm building for).
   2. Check that `build_docker_image.sh` is pointing to an appropriate Docker repository, and run it.
3. Once the Docker image is built, inspect the versions of Python available in the image under `/opt/python/cp*` and update `abi_tags.txt`.
4. Make sure that the variable `docker_image` in `generate_dag.sh` is pointing to the correct image, then run:
   
		./generate_dag.sh <HTCondor branch name> <version identifier>
   
	* The HTCondor branch must already be pushed to the HTCondor GitHub mirror.
	* The version identifier is optional and should follow [PEP 440](https://www.python.org/dev/peps/pep-0440/) (e.g. `a1`, `rc2`, `post1`).
	* This script, along with generating a DAG, also sets up temporary directories under `tmp/` that store the files needed for each build.
5. Submit the DAG: `condor_submit_dag <branch><version>.dag` (e.g. `condor_submit_dag V1_2_3-branchrc3.dag`).
6. Built wheels will end up in `wheels/`.
    * Inspect a few of the `out`, `err`, and `log` files in the `tmp/<build directories>/` for problems.
7. Upload the wheels. You'll want to install the Python package `twine` (perhaps in a miniconda environment):

		cd wheels
		twine upload htcondor-<htcondor version><version identifier>-*.whl

8. It's your choice to delete old `tmp/` directories and old wheel files.
