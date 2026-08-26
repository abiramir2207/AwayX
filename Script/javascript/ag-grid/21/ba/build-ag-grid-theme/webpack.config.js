// config/webpack.dev.js
/* const HtmlWebpackPlugin = require('html-webpack-plugin'); */

const MiniCssExtractPlugin = require('mini-css-extract-plugin');


module.exports = {
    mode: 'none',
    entry: './src/js/dependencies.js',
    devtool: 'cheap-module-eval-source-map',

    output: {
        filename: './delete/dummy-bundle.js'
    },

    module: {
        rules: [
            /*
            {
                test: /\.ts$/,
                loader: 'ts-loader'
            },
            {
                test: /\.html$/,
                loader: 'html-loader'
            },
            */
           /*
            {
                test: /\.scss$/,
                use: ['style-loader?sourceMap=true', 
                'css-loader?sourceMap=true', 
                'sass-loader?sourceMap=true']
            },
            */
           {
                test: /\.scss$/,
                use: [
                    {
                      loader: MiniCssExtractPlugin.loader
                    },
                    {
                        loader: 'css-loader',
                        options: {
                            sourceMap: true
                        }
                    },
                    'sass-loader?sourceMap=true'
                ]
            },
            {
                test: /\.(woff|woff2|eot|ttf|svg)$/,
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
        new MiniCssExtractPlugin({filename: "../ba-ag-theme-balham.css"})
        ],
};