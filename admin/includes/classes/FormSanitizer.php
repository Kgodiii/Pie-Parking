<?php

    class FormSanitizer{

        public static function sanitizeFormString($input){

            //Remove any code tags to prevent script injection
            $input = strip_tags($input);
            //Remove any leading or trailing spaces
            $input = trim($input);

            return $input;

        }

    }

?>