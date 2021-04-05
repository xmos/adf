# Copyright 2021 XMOS LIMITED. This Software is subject to the terms of the
# XMOS Public License: Version 1
import setuptools

LIB_XCORE_INTERPRETERS = [
    "libs/linux/libxcore_interpreters.so",
    "libs/linux/libxcore_interpreters.so.1.0.1",
    "libs/macos/libxcore_interpreters.dylib",
    "libs/macos/libxcore_interpreters.1.0.1.dylib",
]

EXCLUDES = ["*tests", "*tests.*", "cmake", "python_bindings", "xcore_firmware"]

INSTALL_REQUIRES = [
    "numpy<2.0",
    "portalocker==2.0.0",
]

setuptools.setup(
    name="xcore_interpreters",
    packages=setuptools.find_packages(exclude=EXCLUDES),
    python_requires=">=3.8.0",
    install_requires=INSTALL_REQUIRES,
    extras_require={
        "test": [
            "pytest>=5.2.0",
        ],
    },
    package_data={"": LIB_XCORE_INTERPRETERS},
    author="XMOS",
    author_email="support@xmos.com",
    description="XMOS TensorFlow Lite model interpreters.",
    license="LICENSE.txt",
    keywords="xmos xcore",
    use_scm_version={
        "root": "..",
        "relative_to": __file__,
        "version_scheme": "post-release",
    },
    setup_requires=["setuptools_scm"],
)
