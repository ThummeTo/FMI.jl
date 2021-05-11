//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "main.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

const char* fmi2StatusString(fmi2Status status)
{
    switch(status)
    {
        case fmi2OK:
            return "OK";
        case fmi2Warning:
            return "Warning";
        case fmi2Discard:
            return "Discard";
        case fmi2Error:
            return "Error";
        case fmi2Fatal:
            return "Fatal";
        case fmi2Pending:
            return "Pending";
        default:
            return "Unknwon";
    }
}

// FMI-Specification 2.0.2 p.20 ff
void logger(fmi2ComponentEnvironment componentEnvironment,
            fmi2String instanceName,
            fmi2Status status,
            fmi2String category,
            fmi2String message, ...)
{
    va_list args;
    size_t size;
    char* msgBuffer;

    va_start(args, message);

    size = vsnprintf(NULL, 0, message, args);
    msgBuffer = (char*) calloc(size+1, sizeof(char));

    vsprintf(msgBuffer, message, args);
    printf("[%s][%s][%s]: %s\n", fmi2StatusString(status), category, instanceName, msgBuffer);

    free(msgBuffer);
    va_end(args);
}

/* HELPER to allocate C-Struct */
fmi2CallbackFunctions* allocateFmi2CallbackFunctions(void)
{
    fmi2CallbackFunctions* cbf = (fmi2CallbackFunctions*)malloc(sizeof(fmi2CallbackFunctions));
    cbf->logger = logger;
    cbf->allocateMemory = calloc;
    cbf->freeMemory = free;
    cbf->stepFinished = NULL;
    cbf->componentEnvironment = NULL;
    return cbf;
}

/* HELPER to free C-Struct */
void freeFmi2CallbackFunctions(fmi2CallbackFunctions* cbf)
{
    free(cbf);
}

// FMI-Specification 2.0.2 p.20 ff
void* allocateMemory(size_t nobj, size_t size)
{
	void* ptr = calloc(nobj, size);
	//printf("[OK]: allocateMemory()\n");
	return ptr;
}

// FMI-Specification 2.0.2 p.20 ff
void freeMemory(void* obj)
{
	free(obj);
	//printf("[OK]: freeMemory()\n");
}

// FMI-Specification 2.0.2 p.20 ff
void stepFinished(fmi2ComponentEnvironment componentEnvironment, fmi2Status status)
{
    //printf("[OK]: stepFinished()\n");
}
