﻿// -------------------------------------------------------------------------------------------
// <copyright file="ScreenAwareLayoutControl.cs" company="MapWindow OSS Team - www.mapwindow.org">
//  MapWindow OSS Team - 2015
// </copyright>
// -------------------------------------------------------------------------------------------

using System;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Globalization;
using System.Linq;
using System.Windows.Forms;
using MW5.Plugins.Printing.Enums;
using MW5.Plugins.Printing.Helpers;
using MW5.Plugins.Printing.Model.Elements;
using MW5.Shared;

namespace MW5.Plugins.Printing.Controls.Layout
{
    [ToolboxItem(false)]
    public class ScreenAwareLayoutControl : ZoomableLayoutControl
    {
        private readonly SolidBrush _selectionBrush;
        private readonly SolidBrush _marginBrush;
        private readonly Pen _selectionPen;
        protected RectangleF _mouseBox;
        protected MouseMode _mouseMode;
        protected Bitmap _resizeTempBitmap;
        protected bool _showPageNumbers;
        private bool _showMargins;

        protected ScreenAwareLayoutControl()
        {
            _selectionBrush = new SolidBrush(Color.Transparent);
            _selectionPen = new Pen(Color.Orange, 2f);
            _marginBrush = new SolidBrush(Color.FromArgb(240, 240, 240));
            _showMargins = true;
            DrawingQuality = SmoothingMode.HighQuality;
        }

        /// <summary>
        /// Gets or sets the smoothing mode to use to draw the map
        /// </summary>
        public SmoothingMode DrawingQuality { get; set; }

        public Color SelectionColor
        {
            get { return _selectionPen.Color; }
            set
            {
                _selectionPen.Color = value;
                Invalidate();
            }
        }

        public LayoutMap MainMap
        {
            get { return _layoutElements.OfType<LayoutMap>().FirstOrDefault(map => map.MainMap); }
        }

        public bool MutipleMaps
        {
            get { return _layoutElements.OfType<LayoutMap>().Count() > 1; }
        }

        /// <summary>
        /// Sets a boolean flag indicating if margins should be shown.
        /// </summary>
        public bool ShowMargins
        {
            get { return _showMargins; }
            set
            {
                _showMargins = value;
                Invalidate();
            }
        }

        /// <summary>
        /// Gets or sets whether page numbers will be displayed
        /// </summary>
        public virtual bool ShowPageNumbers
        {
            get { return _showPageNumbers; }
            set
            {
                _showPageNumbers = value;
                Invalidate();
            }
        }

        /// <summary>
        /// Drawing code
        /// </summary>
        protected override void OnPaint(PaintEventArgs e)
        {
            if (!Initialized)
            {
                return;
            }

            //Deal with invalidate rectangles that have a size of 0
            if (e.ClipRectangle.Width <= 0 || e.ClipRectangle.Height <= 0)
            {
                return;
            }

            //Store the cursor so we can show an hour glass while drawing
            var oldCursor = Cursor;

            e.Graphics.SmoothingMode = SmoothingMode.None;

            DrawControl(e.Graphics, e.ClipRectangle);

            //resets the cursor cuz some times it get jammed
            Cursor = oldCursor;
        }

        /// <summary>
        /// Prevents flicker from any default on paint background operations
        /// </summary>
        protected override void OnPaintBackground(PaintEventArgs e)
        {
        }

        /// <summary>
        /// Main rendring routine, uses double buffering.
        /// </summary>
        private void DrawControl(Graphics g, Rectangle clipRectangle)
        {
            //Updates the invalidation rectangle to be a bit bigger to deal with overlaps
            var invalRect = Rectangle.Inflate(clipRectangle, 5, 5);

            if (invalRect.X < 0) invalRect.X = 0;
            if (invalRect.Y < 0) invalRect.Y = 0;

            //We paint to a temporary buffer to avoid flickering
            using (var tempBuffer = new Bitmap(invalRect.Width, invalRect.Height, PixelFormat.Format24bppRgb))
            {
                using (var graph = Graphics.FromImage(tempBuffer))
                {
                    graph.TranslateTransform(-invalRect.X, -invalRect.Y);
                    graph.SmoothingMode = DrawingQuality;

                    graph.FillRectangle(Brushes.DarkGray, invalRect);

                    DrawPages(graph);

                    for (int i = LayoutElements.Count - 1; i >= 0; i--)
                    {
                        DrawElement(graph, LayoutElements[i], invalRect, i);
                    }

                    DrawSelectionRectangles(graph);

                    DrawMainMap(graph);

                    DrawPageNumbers(graph);

                    DrawRubberBand(graph);

                    DrawRulers(graph);

                    g.SmoothingMode = DrawingQuality;

                    // draws buffer on the screen
                    var r = new RectangleF(0f, 0f, invalRect.Width, invalRect.Height);
                    g.DrawImage(tempBuffer, invalRect, r, GraphicsUnit.Pixel);
                }
            }
        }



        private void DrawRulersFrame(Graphics g, Pen pen, int rulerWidth)
        {
            var brush = new SolidBrush(Color.WhiteSmoke);
            g.FillRectangle(brush, 0, 0, Width, rulerWidth);
            g.FillRectangle(brush, 0, 0, rulerWidth, Height);

            g.DrawLine(pen, 0, 0, 0, Height);
            g.DrawLine(pen, 0, 0, Width, 0);
            g.DrawLine(pen, rulerWidth, rulerWidth, rulerWidth, Height);
            g.DrawLine(pen, rulerWidth, rulerWidth, Width, rulerWidth);
        }

        /// <summary>
        /// Draws horizontal and verical rulers with paper size.
        /// </summary>
        private void DrawRulers(Graphics g)
        {
            const int rulerWidth = 18;

            var pen = Pens.Gray;

            DrawRulersFrame(g, pen, rulerWidth);

            int step = ChooseRulerStep();

            var originPaper = ScreenToPaper(rulerWidth, rulerWidth);
            originPaper = new PointF((float)(Math.Floor(originPaper.X / step) * step), (float)(Math.Floor(originPaper.Y / step) * step));

            var start = PaperToScreen(originPaper);

            DrawRuler(g, pen, Convert.ToInt32(originPaper.X), start.X, Width, rulerWidth, step, false);
            
            // let's reuse the same rendering code for vertical ruler
            g.RotateTransform(90f);
            g.TranslateTransform(rulerWidth, 0f, MatrixOrder.Append);

            DrawRuler(g, pen, Convert.ToInt32(originPaper.Y), start.Y, Height, rulerWidth, step, true);

            g.ResetTransform();
        }

        /// <summary>
        /// Returns ruler step in 1/100 of an inch
        /// </summary>
        private int ChooseRulerStep()
        {
            float ratio = PixelsPerDot();
            double step = 1;

            int byTwo = 0;
            while (ratio * step < 70f)
            {
                step = byTwo < 2 ? step * 2 : step * 2.5;
                byTwo++;
                if (byTwo == 3) byTwo = 0;
            }

            return Convert.ToInt32(step);
        }

        /// <summary>
        /// Draws the ruler, eithe horizontal or vertical.
        /// </summary>
        private void DrawRuler(Graphics g, Pen pen, int paperStart, float screenStart, float screenEnd, float rulerWidth, int step, bool vertical)
        {
            float ratio = PixelsPerDot();
            float screenStep = step * ratio / 10f;

            var textBrush = Brushes.Black;

            float val = screenStart;
            while (val < screenEnd)
            {
                if (val > rulerWidth)
                {
                    g.DrawLine(pen, Convert.ToInt32(val), 0, Convert.ToInt32(val), rulerWidth);
                    g.DrawString(paperStart.ToString(CultureInfo.InvariantCulture), Font, textBrush, val + 1, vertical ? rulerWidth * 0.25f : 0);
                }

                for (int i = 0; i < 10; i++)
                {
                    int valTemp = Convert.ToInt32(val + screenStep * i);

                    if (valTemp < rulerWidth)
                    {
                        continue;
                    }

                    float size = Convert.ToInt32((i == 5) ? rulerWidth / 2f : rulerWidth * 0.75f);

                    if (vertical)
                    {
                        size = rulerWidth - size;
                    }

                    g.DrawLine(pen, valTemp, size, valTemp, (vertical ? 0f : rulerWidth));
                }

                val += screenStep * 10;
                paperStart += step;
            }
        }

        /// <summary>
        /// Draws a single element of the layout.
        /// </summary>
        private void DrawElement(Graphics g, LayoutElement le, Rectangle invalRect, int index)
        {
            bool panning = _mouseMode == MouseMode.PanMap && IsSelected(index) && le is LayoutMap &&
                           _selectedLayoutElements.Count == 1;

            if (!panning && DrawMapResizing(index, g))
            {
                return;
            }

            float x = panning ? _paperLocation.X + _mouseBox.Width : _paperLocation.X;
            float y = panning ? _paperLocation.Y + _mouseBox.Height : _paperLocation.Y;

            g.TranslateTransform(x, y);
            g.ScaleTransform(ScreenHelper.LogicToScreenDpi * _zoom, ScreenHelper.LogicToScreenDpi * _zoom);

            le.DrawElement(g, false, false);

            g.ResetTransform();
            g.TranslateTransform(-invalRect.X, -invalRect.Y);
        }

        /// <summary>
        /// Draws a tag for the main map.
        /// </summary>
        private void DrawMainMap(Graphics g)
        {
            bool multipleMaps = MutipleMaps;
            if (multipleMaps)
            {
                var mainMap = MainMap;
                if (mainMap != null)
                {
                    var leRect = PaperToScreen(mainMap.Rectangle);
                    const string s = "Main map";
                    var size = g.MeasureString(s, Font);
                    var tempR = new RectangleF(leRect.Location, size);
                    g.FillRectangle(Brushes.White, tempR);
                    g.DrawString(s, Font, new SolidBrush(Color.Black), tempR);
                }
            }
        }

        /// <summary>
        /// Draws map element during resizing.
        /// </summary>
        private bool DrawMapResizing(int index, Graphics graph)
        {
            if (IsSelected(index) && _resizeTempBitmap != null)
            {
                var el = _selectedLayoutElements[0];

                var papRect = PaperToScreen(el.Rectangle);
                var clipRect = papRect.FloatRectangleToInt();

                switch (el.ResizeStyle)
                {
                    case ResizeStyle.StretchToFit:
                        graph.DrawImage(_resizeTempBitmap, clipRect);
                        break;
                    case ResizeStyle.NoScaling:
                        graph.DrawImageUnscaled(_resizeTempBitmap, clipRect);
                        break;
                }

                return true;
            }

            return false;
        }

        /// <summary>
        /// Draws the page numbers.
        /// </summary>
        private void DrawPageNumber(Graphics g, RectangleF paperRect, int pageX, int pageY)
        {
            float fontSize = _pages.PageWidth > _pages.PageHeight
                                 ? _pages.PageWidth /* looks suspicios */
                                 : (float)_pages.PageHeight / 10 * _zoom;

            var font = new Font(Font.FontFamily, fontSize);

            var numbersColor = Color.Gray;
            var color = _pages.GetPage(pageX, pageY).Selected ? Color.Orange : numbersColor;

            var brush = new SolidBrush(color);
            var ellipsePen = new Pen(color) { Width = 40 * _zoom };

            int pageId = pageY * _pages.PageCountX + pageX + 1;

            g.DrawString(pageId.ToString(CultureInfo.InvariantCulture), font, brush, paperRect,
                GdiPlusHelper.CenterFormat);

            var size = (int)(fontSize * 3.0);

            var x = (int)(paperRect.X + paperRect.Width / 2f - size / 2.0f);
            var y = (int)(paperRect.Y + paperRect.Height / 2f - size / 2.0f);

            var loc = new Point(x, y);
            var r = new Rectangle(loc, new Size(size, size));

            g.DrawEllipse(ellipsePen, r);
        }

        /// <summary>
        /// Draws page numbers.
        /// </summary>
        private void DrawPageNumbers(Graphics g)
        {
            if (!_showPageNumbers) return;

            for (int i = 0; i < _pages.PageCountX; i++)
            {
                for (int j = 0; j < _pages.PageCountY; j++)
                {
                    float x = _pages.GetPagePositionX(i);
                    float y = _pages.GetPagePositionY(j);

                    var paperRect = PaperToScreen(x, y, _pages.PageWidth, _pages.PageHeight);

                    // page number
                    DrawPageNumber(g, paperRect, i, j);
                }
            }
        }

        private RectangleF GetPaperBoundsWithMargins()
        {
            var page = PrinterSettings.DefaultPageSettings;

            float width = _pages.TotalWidth + page.Margins.Left + page.Margins.Right;
            float height = _pages.TotalHeight + page.Margins.Top + page.Margins.Bottom;

            return PaperToScreen(-page.Margins.Left, -page.Margins.Top, width, height);
        }

        /// <summary>
        /// Draws pages of the layout control
        /// </summary>
        private void DrawPages(Graphics g)
        {
            var pen = new Pen(Color.Gray) { DashStyle = DashStyle.Dash };

            var rect = PaperToScreen(0, 0, _pages.TotalWidth, _pages.TotalHeight);
            var bounds = GetPaperBoundsWithMargins();

            g.FillRectangle(Brushes.White, ShowMargins ? bounds : rect);

            for (int i = 0; i < _pages.PageCountX; i++)
            {
                for (int j = 0; j < _pages.PageCountY; j++)
                {
                    float x = _pages.GetPagePositionX(i);
                    float y = _pages.GetPagePositionY(j);

                    var paperRect = PaperToScreen(x, y, _pages.PageWidth, _pages.PageHeight);

                    g.DrawLine(pen, paperRect.Left, paperRect.Top, paperRect.Left + paperRect.Width, paperRect.Top);
                    g.DrawLine(pen, paperRect.Left, paperRect.Top, paperRect.Left, paperRect.Top + paperRect.Height);
                }
            }

            // outside border
            var r = _showMargins ? bounds: rect;
            g.DrawRectangle(Pens.Black, r.X, r.Y, r.Width, r.Height);

            if (ShowMargins)
            {
                g.DrawLine(pen, rect.Right, rect.Top, rect.Right, rect.Bottom);
                g.DrawLine(pen, rect.Left, rect.Bottom, rect.Right, rect.Bottom);
            }
        }

        private void DrawRubberBand(Graphics g)
        {
            //If the users is dragging a select box or an insert box we draw it here
            if (_mouseMode == MouseMode.CreateSelection || _mouseMode == MouseMode.InsertNewElement)
            {
                var boxColor = _mouseMode == MouseMode.CreateSelection ? SystemColors.Highlight : Color.Orange;
                var outlinePen = new Pen(boxColor);
                using (var highlightBrush = new SolidBrush(Color.FromArgb(30, boxColor)))
                {
                    g.FillRectangle(highlightBrush, _mouseBox.X, _mouseBox.Y, _mouseBox.Width - 1, _mouseBox.Height - 1);
                    g.DrawRectangle(outlinePen, _mouseBox.X, _mouseBox.Y, _mouseBox.Width - 1, _mouseBox.Height - 1);
                }
            }
        }

        /// <summary>
        /// Draws the selection rectangle around each selected item
        /// </summary>
        private void DrawSelectionRectangles(Graphics g)
        {
            foreach (var layoutEl in _selectedLayoutElements.Where(el => el.Visible))
            {
                var leRect = PaperToScreen(layoutEl.Rectangle);
                var r = leRect.FloatRectangleToInt();
                g.DrawRectangle(_selectionPen, r);
                g.FillRectangle(_selectionBrush, r);
            }
        }
    }
}