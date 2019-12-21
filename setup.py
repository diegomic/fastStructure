
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy
import sys

setup(name='fastStructure',
      install_requires=[
          'logzero',
          'numpy',
          'scipy',
      ],
      description="fastStructure is a fast algorithm for inferring population structure from large SNP genotype data.",
      license="MIT",
      cmdclass={'build_ext': build_ext},
      # see https://stackoverflow.com/questions/21826137/cython-setup-py-for-several-pyx
      ext_modules=[Extension("parse_bed", ["parse_bed.pyx"],
                             include_dirs=[numpy.get_include(), '.']),
                   Extension("parse_str", ["parse_str.pyx"],
                             include_dirs=[numpy.get_include(), '.']),
                   Extension("fastStructure", ["fastStructure.pyx"],
                             include_dirs=[numpy.get_include(), '.', 'vars/'])]
      )
