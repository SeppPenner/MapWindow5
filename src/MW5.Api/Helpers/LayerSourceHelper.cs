﻿using System;
using System.Collections.Generic;
using MapWinGIS;
using MW5.Api.Concrete;
using MW5.Api.Enums;
using MW5.Api.Interfaces;

namespace MW5.Api.Helpers
{
    public static class LayerSourceHelper
    {
        public static ILayerSource Open(string filename, LayerType layerType)
        {
            switch (layerType)
            {
                case LayerType.Shapefile:
                    var fs = new FeatureSet(filename);
                    return fs;
                case LayerType.Image:
                    var img = BitmapSource.Open(filename, false);
                    return img;
                case LayerType.VectorLayer:
                    var ogr = new OgrLayer();
                    var vector = new VectorLayer(ogr);
                    return vector;
                default:
                    throw new ArgumentOutOfRangeException("layerType");
            }
        }
        
        public static IDatasource Convert(object source)
        {
            if (source is OgrDatasource)
            {
                return new VectorDatasource(source as OgrDatasource);
            }
            return ConvertToLayer(source);
        }

        public static ILayerSource ConvertToLayer(object source)
        {
            if (source is Shapefile)
            {
                return new FeatureSet(source as Shapefile);
            }
            if (source is Image)
            {
                return BitmapSource.Wrap(source as Image);
            }
            if (source is OgrLayer)
            {
                return new VectorLayer(source as OgrLayer);
            }
            if (source is Grid)
            {
                return new GridSource(source as Grid);
            }
            return null;
        }

        public static IEnumerable<ILayerSource> GetLayers(IDatasource ds)
        {
            var vs = ds as VectorDatasource;
            if (vs != null)
            {
                foreach (var layer in vs)
                {
                    yield return layer;
                }
            }
            else
            {
                yield return ds as ILayerSource;
            }
        }
    }
}
