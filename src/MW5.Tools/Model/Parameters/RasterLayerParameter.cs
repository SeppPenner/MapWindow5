﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MW5.Api.Interfaces;
using MW5.Plugins.Enums;

namespace MW5.Tools.Model.Parameters
{
    public class RasterLayerParameter : LayerParameterBase<IRasterSource>
    {
        public override DataSourceType DataSourceType
        {
            get { return DataSourceType.Raster; }
        }
    }
}