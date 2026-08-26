// config/webpack.dev.js
var webpack = require('webpack');
var path = require('path');

var ExtractTextPlugin = require('extract-text-webpack-plugin');
//var HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    devtool: 'cheap-module-eval-source-map',

    entry: './src/js/dependencies.js',

    output: {
        filename: './delete/dummy-bundle.js'
    },

    module: {
        loaders: [
            /*
            {
                test: /\.ts$/,
                loader: 'ts-loader'
            },
            {
                test: /\.html$/,
                loader: 'html-loader'
            }, */
          /*  {
                test: /\.scss$/,
                    use: ['style-loader?sourceMap=true', 
                    'css-loader?sourceMap=true', 
                    'sass-loader?sourceMap=true']
            }, */
            {
                test: /\.scss$/,
                use: ExtractTextPlugin.extract({
                    use: [
                    'css-loader?sourceMap=true', 
                    'sass-loader?sourceMap=true']
                })
            },
            {
                test: /\.svg$/,
                use: [
                    {loader: 'url-loader'},
                    {
                        loader: 'svg-colorize-loader',
                        /* options: {
                            color1: '#000000',
                            color2: '#FFFFFF'
                        } */
                    }
                ]
            }
        ]
    },
    
    plugins: [
        /*
        new HtmlWebpackPlugin({
            template: 'index_template.html',
            filename: 'index.html'
        }),
        */
        new ExtractTextPlugin({
            /* filename: "./dist/styles/[name].css" */
            filename: "../ba-ag-theme-balham.css"
        })
    ]

};
