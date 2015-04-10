﻿using System;
using AxMapWinGIS;
using MapWinGIS;
using MW5.Api.Enums;

namespace MW5.Api.Events
{
    public class BeforeDeleteShapeEventArgs : EventArgs
    {
        private readonly _DMapEvents_BeforeDeleteShapeEvent _args;

        internal BeforeDeleteShapeEventArgs(_DMapEvents_BeforeDeleteShapeEvent args)
        {
            _args = args;
            if (args == null)
            {
                throw new NullReferenceException("Internal reference is null.");
            }
        }

        public bool Cancel
        {
            get { return _args.cancel == tkMwBoolean.blnTrue; }
            set { _args.cancel = value ? tkMwBoolean.blnTrue: tkMwBoolean.blnFalse; }
        }

        public DeleteTarget Target
        {
            get { return (DeleteTarget)_args.target; }
        }
    }
}
