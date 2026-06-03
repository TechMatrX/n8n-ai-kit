#!/bin/bash

SPACE_ID=zwunn1buds8f
ENV_ID=master
FILE_PATH=contentful-blog-post-export.json

if ! command -v contentful &> /dev/null; then
    echo "Contentful CLI not found"
    exit 1
fi

if [ ! -f "${FILE_PATH}" ]; then
    echo "File not found: ${FILE_PATH}"
    exit 1
fi

if [ -z "${CONTENTFUL_MANAGEMENT_TOKEN}" ]; then
    echo "CONTENTFUL_MANAGEMENT_TOKEN is not set"
    exit 1
fi

contentful space import \
    --space-id "${SPACE_ID}" \
    --environment-id "${ENV_ID}" \
    --content-file "${FILE_PATH}" \
    --management-token "${CONTENTFUL_MANAGEMENT_TOKEN}"
