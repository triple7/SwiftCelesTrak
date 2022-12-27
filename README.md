# SwiftCelesTrak

A swift wrapper for the [CelesTrak API](https://celestrak.org/NORAD/documentation/gp-data-formats.php)

## Introduction

The US government has provided GP or general perturbations orbital data to the rest of the world since the 1970s. These data are produced by fitting observations from the US Space Surveillance Network (SSN) to produce Brouwer mean elements using the SGP4 or Simplified General Perturbations 4 orbit propagator.

The CelesTrak API allows for an updated [CCSDS 502.0-B-2](https://public.ccsds.org/Pubs/502x0b2c1e2.pdf) standard compliant GP data standard developed by [The Consultative Committee for Space Data Systems (CCSDS)](https://public.ccsds.org/default.aspx) to monitor over 100,000 objects in current low to high earth orbit.

## Standard http requests 

SwiftCelesTrak wraps the set of standard http request parameters to retrieve GP data in various formats such as:
. JSON
. XML
. CSV

Other formats such as TLE are not implemented as they are legacy data formats and CelesTrak is futureproof with the transition of the TLE data format to the new OMM catalog format which allows for identification integers upwards of 99,999 which the TLE format lacks.

